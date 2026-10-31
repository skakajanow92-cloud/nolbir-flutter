#include "graph/GraphStore.hpp"

#include <deque>
#include <unordered_map>
#include <unordered_set>

namespace litedb {

Database& GraphStore::init(Database& db) {
  db.exec(
      "CREATE TABLE IF NOT EXISTS nodes("
      "  id    TEXT PRIMARY KEY,"
      "  label TEXT NOT NULL DEFAULT '',"
      "  props TEXT NOT NULL DEFAULT '{}' CHECK(json_valid(props))"
      ") WITHOUT ROWID;"
      "CREATE INDEX IF NOT EXISTS nodes_label ON nodes(label);"
      "CREATE TABLE IF NOT EXISTS edges("
      "  src   TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,"
      "  rel   TEXT NOT NULL,"
      "  dst   TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,"
      "  props TEXT NOT NULL DEFAULT '{}' CHECK(json_valid(props)),"
      "  PRIMARY KEY(src, rel, dst)"
      ") WITHOUT ROWID;"
      "CREATE INDEX IF NOT EXISTS edges_rev ON edges(dst, rel);");
  return db;
}

GraphStore::GraphStore(Database& db)
    : db_(init(db)),
      // UPSERT: INSERT OR REPLACE kullanilmaz, cunku REPLACE satiri silip
      // yeniden ekler ve bagli kenarlari CASCADE ile yok ederdi.
      addNode_(db,
               "INSERT INTO nodes(id,label,props) VALUES(?1,?2,?3) "
               "ON CONFLICT(id) DO UPDATE SET label=excluded.label, "
               "props=excluded.props"),
      getNode_(db, "SELECT id,label,props FROM nodes WHERE id=?1"),
      delNode_(db, "DELETE FROM nodes WHERE id=?1"),
      byLabel_(db, "SELECT id FROM nodes WHERE label=?1 ORDER BY id"),
      addEdge_(db,
               "INSERT INTO edges(src,rel,dst,props) VALUES(?1,?2,?3,?4) "
               "ON CONFLICT(src,rel,dst) DO UPDATE SET props=excluded.props"),
      delEdge_(db, "DELETE FROM edges WHERE src=?1 AND rel=?2 AND dst=?3"),
      hasEdge_(db, "SELECT 1 FROM edges WHERE src=?1 AND rel=?2 AND dst=?3"),
      outEdges_(db,
                "SELECT src,rel,dst,props FROM edges "
                "WHERE src=?1 AND (?2='' OR rel=?2) ORDER BY rel,dst"),
      inEdges_(db,
               "SELECT src,rel,dst,props FROM edges "
               "WHERE dst=?1 AND (?2='' OR rel=?2) ORDER BY rel,src"),
      countNodes_(db, "SELECT COUNT(*) FROM nodes"),
      countEdges_(db, "SELECT COUNT(*) FROM edges") {}

// ---------- Dugumler ----------

void GraphStore::addNode(const std::string& id, const std::string& label,
                         const std::string& propsJson) {
  addNode_.reset().bind(1, id).bind(2, label).bind(3, propsJson).run();
}

std::optional<GraphStore::Node> GraphStore::getNode(const std::string& id) {
  getNode_.reset().bind(1, id);
  std::optional<Node> out;
  if (getNode_.step())
    out = Node{getNode_.text(0), getNode_.text(1), getNode_.text(2)};
  getNode_.reset();
  return out;
}

bool GraphStore::removeNode(const std::string& id) {
  delNode_.reset().bind(1, id).run();
  return db_.changes() > 0;
}

std::vector<std::string> GraphStore::nodesByLabel(const std::string& label) {
  byLabel_.reset().bind(1, label);
  std::vector<std::string> out;
  while (byLabel_.step()) out.push_back(byLabel_.text(0));
  byLabel_.reset();
  return out;
}

// ---------- Kenarlar ----------

void GraphStore::addEdge(const std::string& src, const std::string& rel,
                         const std::string& dst, const std::string& propsJson) {
  addEdge_.reset().bind(1, src).bind(2, rel).bind(3, dst).bind(4, propsJson).run();
}

bool GraphStore::removeEdge(const std::string& src, const std::string& rel,
                            const std::string& dst) {
  delEdge_.reset().bind(1, src).bind(2, rel).bind(3, dst).run();
  return db_.changes() > 0;
}

bool GraphStore::hasEdge(const std::string& src, const std::string& rel,
                         const std::string& dst) {
  hasEdge_.reset().bind(1, src).bind(2, rel).bind(3, dst);
  bool found = hasEdge_.step();
  hasEdge_.reset();
  return found;
}

// ---------- Sorgular ----------

void GraphStore::collectEdges(Statement& st, const std::string& id,
                              const std::string& rel, bool skipSelfLoops,
                              std::vector<Edge>& out) {
  st.reset().bind(1, id).bind(2, rel);
  while (st.step()) {
    Edge e{st.text(0), st.text(1), st.text(2), st.text(3)};
    if (skipSelfLoops && e.src == e.dst) continue;
    out.push_back(std::move(e));
  }
  st.reset();
}

std::vector<GraphStore::Edge> GraphStore::edgesOf(const std::string& id,
                                                  const std::string& rel,
                                                  Direction dir) {
  std::vector<Edge> out;
  if (dir == Direction::Out || dir == Direction::Both)
    collectEdges(outEdges_, id, rel, false, out);
  if (dir == Direction::In || dir == Direction::Both)
    // Both modunda kendine dongu (self-loop) zaten Out'ta sayildi.
    collectEdges(inEdges_, id, rel, dir == Direction::Both, out);
  return out;
}

std::vector<std::string> GraphStore::neighbors(const std::string& id,
                                               const std::string& rel,
                                               Direction dir) {
  std::vector<std::string> out;
  std::unordered_set<std::string> seen;
  for (const Edge& e : edgesOf(id, rel, dir)) {
    const std::string& other = (e.src == id) ? e.dst : e.src;
    if (seen.insert(other).second) out.push_back(other);
  }
  return out;
}

std::vector<GraphStore::Visit> GraphStore::traverse(const std::string& start,
                                                    int maxDepth,
                                                    const std::string& rel,
                                                    Direction dir) {
  std::vector<Visit> out;
  if (!getNode(start)) return out;
  std::unordered_set<std::string> seen{start};
  std::deque<Visit> queue{{start, 0}};
  while (!queue.empty()) {
    Visit cur = queue.front();
    queue.pop_front();
    if (cur.depth >= maxDepth) continue;
    for (const std::string& n : neighbors(cur.id, rel, dir)) {
      if (!seen.insert(n).second) continue;  // donguleri engeller
      Visit v{n, cur.depth + 1};
      out.push_back(v);
      queue.push_back(v);
    }
  }
  return out;
}

std::vector<std::string> GraphStore::shortestPath(const std::string& from,
                                                  const std::string& to,
                                                  int maxDepth,
                                                  const std::string& rel,
                                                  Direction dir) {
  if (!getNode(from) || !getNode(to)) return {};
  if (from == to) return {from};

  std::unordered_map<std::string, std::string> parent{{from, ""}};
  std::deque<Visit> queue{{from, 0}};
  while (!queue.empty()) {
    Visit cur = queue.front();
    queue.pop_front();
    if (cur.depth >= maxDepth) continue;
    for (const std::string& n : neighbors(cur.id, rel, dir)) {
      if (parent.count(n)) continue;
      parent[n] = cur.id;
      if (n == to) {
        std::vector<std::string> path;
        for (std::string at = to; !at.empty(); at = parent[at]) path.push_back(at);
        return {path.rbegin(), path.rend()};
      }
      queue.push_back({n, cur.depth + 1});
    }
  }
  return {};
}

long long GraphStore::countNodes() {
  countNodes_.reset();
  long long n = countNodes_.step() ? countNodes_.int64(0) : 0;
  countNodes_.reset();
  return n;
}

long long GraphStore::countEdges() {
  countEdges_.reset();
  long long n = countEdges_.step() ? countEdges_.int64(0) : 0;
  countEdges_.reset();
  return n;
}

}  // namespace litedb
