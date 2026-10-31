#pragma once
#include <optional>
#include <string>
#include <vector>

#include "core/Database.hpp"
#include "core/Statement.hpp"

namespace litedb {

enum class Direction { Out, In, Both };

// Neo4j benzeri ozellikli graf deposu. Dugumler `nodes`, kenarlar `edges`
// tablosundadir. Kenar eklemeden once iki dugum de var olmalidir; bir dugum
// silinince ona bagli tum kenarlar da otomatik silinir (ON DELETE CASCADE).
class GraphStore {
 public:
  struct Node {
    std::string id, label, props;  // props: JSON metni
  };
  struct Edge {
    std::string src, rel, dst, props;
  };
  struct Visit {
    std::string id;
    int depth;
  };

  explicit GraphStore(Database& db);

  // --- Dugumler ---
  // Ekler veya ayni id varsa gunceller (kenarlara dokunmaz).
  void addNode(const std::string& id, const std::string& label = "",
               const std::string& propsJson = "{}");
  std::optional<Node> getNode(const std::string& id);
  // Dugumu ve bagli tum kenarlari siler. Dugum vardiysa true.
  bool removeNode(const std::string& id);
  std::vector<std::string> nodesByLabel(const std::string& label);

  // --- Kenarlar ---
  // Iki dugum da yoksa SqliteError. Ayni (src,rel,dst) varsa props guncellenir.
  void addEdge(const std::string& src, const std::string& rel,
               const std::string& dst, const std::string& propsJson = "{}");
  bool removeEdge(const std::string& src, const std::string& rel,
                  const std::string& dst);
  bool hasEdge(const std::string& src, const std::string& rel,
               const std::string& dst);

  // --- Sorgular --- (rel bos ise her iliski turu)
  std::vector<std::string> neighbors(const std::string& id,
                                     const std::string& rel = "",
                                     Direction dir = Direction::Out);
  std::vector<Edge> edgesOf(const std::string& id, const std::string& rel = "",
                            Direction dir = Direction::Out);

  // BFS: baslangictan en fazla maxDepth adimda ulasilan dugumler
  // (baslangic haric), her biri en kisa mesafesiyle, BFS sirasinda.
  std::vector<Visit> traverse(const std::string& start, int maxDepth,
                              const std::string& rel = "",
                              Direction dir = Direction::Out);

  // En az kenar iceren yol (from ve to dahil). Yol yoksa bos vektor.
  std::vector<std::string> shortestPath(const std::string& from,
                                        const std::string& to, int maxDepth = 10,
                                        const std::string& rel = "",
                                        Direction dir = Direction::Out);

  long long countNodes();
  long long countEdges();

 private:
  static Database& init(Database& db);
  void collectEdges(Statement& st, const std::string& id, const std::string& rel,
                    bool skipSelfLoops, std::vector<Edge>& out);

  Database& db_;
  Statement addNode_, getNode_, delNode_, byLabel_;
  Statement addEdge_, delEdge_, hasEdge_;
  Statement outEdges_, inEdges_;
  Statement countNodes_, countEdges_;
};

}  // namespace litedb
