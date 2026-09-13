import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

enum ImageType { asset, file, memory, network }

enum Layout1 { column, row, none }

class Card1 extends StatelessWidget {
  final ImageType? imageType;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double height;
  final double width;
  final Widget? child;
  final List<Widget>? children;
  final Color cardColor;
  final Color borderColor;
  final Color blurColor;
  final Color primary;
  final Color secondary;
  final double offsetX;
  final double offsetY;
  final bool isBorder;
  final bool isShadow;
  final bool isCircular;
  final bool isShape;
  final Layout1 layout;
  final bool isTap;
  final bool isGradient;
  final bool isLinear;
  final List<double> borderCircular;
  final List<List<double>> borderEliptic;
  final double blurRadius;
  final double spreadRadius;
  final List<double> margin;
  final List<double> padding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onSecondaryLongPress;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureScaleUpdateCallback? onScaleUpdate;
  const Card1({
    super.key,
    this.child,
    this.children = const [],
    this.height = 20,
    this.width = double.infinity,
    this.cardColor = Colors.transparent,
    this.borderColor = Colors.black,
    this.blurColor = Colors.black,
    this.primary = Colors.lightBlue,
    this.secondary = Colors.redAccent,
    this.offsetX = 0,
    this.offsetY = 0,
    this.isBorder = false,
    this.isShadow = false,
    this.isCircular = true,
    this.isShape = false,
    this.layout = Layout1.none,
    this.isTap = false,
    this.isGradient = false,
    this.isLinear = true,
    this.borderCircular = const [0, 0, 0, 0],
    this.borderEliptic = const [
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0],
    ],
    this.blurRadius = 0,
    this.spreadRadius = 0,
    this.margin = const [0, 0, 0, 0],
    this.padding = const [0, 0, 0, 0],
    this.imageType,
    this.imageUrl,
    this.imageBytes,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryLongPress,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.onScaleUpdate,
  });

  ImageProvider? _getImageProvider() {
    if (imageType == null) return null;

    switch (imageType!) {
      case ImageType.asset:
        return imageUrl != null ? AssetImage(imageUrl!) : null;
      case ImageType.network:
        return imageUrl != null ? NetworkImage(imageUrl!) : null;
      case ImageType.file:
        return imageUrl != null ? FileImage(File(imageUrl!)) : null;
      case ImageType.memory:
        return imageBytes != null ? MemoryImage(imageBytes!) : null;
    }
  }

  // DecorationImage oluşturan yardımcı metod
  DecorationImage? _getDecorationImage() {
    final provider = _getImageProvider();
    if (provider == null) return null;

    return DecorationImage(image: provider, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(
        top: margin[0],
        left: margin[1],
        right: margin[2],
        bottom: margin[3],
      ),
      padding: EdgeInsets.only(
        top: padding[0],
        left: padding[1],
        right: padding[2],
        bottom: padding[3],
      ),
      decoration: isShape
          ? ShapeDecoration(
              color: cardColor,
              gradient: isGradient
                  ? isLinear
                        ? LinearGradient(colors: [primary, secondary])
                        : RadialGradient(colors: [primary, secondary])
                  : null,
              image: _getDecorationImage(),
              shadows: [
                BoxShadow(
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                  color: blurColor,
                  offset: Offset(offsetX, offsetY),
                ),
              ],
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: isCircular
                      ? Radius.circular(borderCircular[0])
                      : Radius.elliptical(
                          borderEliptic[0][0],
                          borderEliptic[0][1],
                        ),
                  topRight: isCircular
                      ? Radius.circular(borderCircular[1])
                      : Radius.elliptical(
                          borderEliptic[1][0],
                          borderEliptic[1][1],
                        ),
                  bottomLeft: isCircular
                      ? Radius.circular(borderCircular[2])
                      : Radius.elliptical(
                          borderEliptic[2][0],
                          borderEliptic[2][1],
                        ),
                  bottomRight: isCircular
                      ? Radius.circular(borderCircular[3])
                      : Radius.elliptical(
                          borderEliptic[3][0],
                          borderEliptic[3][1],
                        ),
                ),
              ),
            )
          : BoxDecoration(
              color: cardColor,
              gradient: isGradient
                  ? isLinear
                        ? LinearGradient(colors: [primary, secondary])
                        : RadialGradient(colors: [primary, secondary])
                  : null,
              image: _getDecorationImage(),
              borderRadius: BorderRadius.only(
                topLeft: isCircular
                    ? Radius.circular(borderCircular[0])
                    : Radius.elliptical(
                        borderEliptic[0][0],
                        borderEliptic[0][1],
                      ),
                topRight: isCircular
                    ? Radius.circular(borderCircular[1])
                    : Radius.elliptical(
                        borderEliptic[1][0],
                        borderEliptic[1][1],
                      ),
                bottomLeft: isCircular
                    ? Radius.circular(borderCircular[2])
                    : Radius.elliptical(
                        borderEliptic[2][0],
                        borderEliptic[2][1],
                      ),
                bottomRight: isCircular
                    ? Radius.circular(borderCircular[3])
                    : Radius.elliptical(
                        borderEliptic[3][0],
                        borderEliptic[3][1],
                      ),
              ),
              border: isBorder
                  ? Border.all(color: borderColor, style: BorderStyle.solid)
                  : null,
              boxShadow: isShadow
                  ? [
                      BoxShadow(
                        blurRadius: blurRadius,
                        spreadRadius: spreadRadius,
                        color: blurColor,
                        offset: Offset(offsetX, offsetY),
                      ),
                    ]
                  : null,
            ),
      child: (layout == Layout1.column)
          ? Column(children: children!)
          : (layout == Layout1.row)
          ? Row(children: children!)
          : SizedBox(
              child: isTap
                  ? GestureDetector(
                      onDoubleTap: onDoubleTap,
                      onTap: onTap,
                      onLongPress: onLongPress,
                      onSecondaryTap: onSecondaryTap,
                      onSecondaryLongPress: onSecondaryLongPress,
                      onHorizontalDragUpdate: onHorizontalDragUpdate,
                      onVerticalDragUpdate: onVerticalDragUpdate,
                      onScaleUpdate: onScaleUpdate,
                      child: child,
                    )
                  : child,
            ),
    );
  }
}

class Card2 extends StatelessWidget {
  final double radius;
  final double borderRadius;
  final Widget? child;
  final ImageType? imageType;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final Color circleColor;
  final Color shadowColor;
  final Color borderColor;
  final double spreadRadius;
  final double blurRadius;
  final double offsetX;
  final double offsetY;
  final bool isTap;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onSecondaryLongPress;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureScaleUpdateCallback? onScaleUpdate;
  const Card2({
    super.key,
    this.radius = 0,
    this.borderRadius = 0,
    this.child,
    this.circleColor = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.spreadRadius = 0,
    this.blurRadius = 0,
    this.offsetX = 0,
    this.offsetY = 0,
    this.shadowColor = Colors.transparent,
    this.imageType,
    this.imageUrl,
    this.imageBytes,
    this.isTap = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryLongPress,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.onScaleUpdate,
  });

  ImageProvider? _getImageProvider() {
    if (imageType == null) return null;

    switch (imageType!) {
      case ImageType.asset:
        return imageUrl != null ? AssetImage(imageUrl!) : null;
      case ImageType.network:
        return imageUrl != null ? NetworkImage(imageUrl!) : null;
      case ImageType.file:
        return imageUrl != null ? FileImage(File(imageUrl!)) : null;
      case ImageType.memory:
        return imageBytes != null ? MemoryImage(imageBytes!) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double efectiveRadius =
        ((radius != 0 && borderRadius == 0) || radius > borderRadius)
        ? radius
        : borderRadius;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: Offset(offsetX, offsetY),
          ),
        ],
      ),
      child: isTap
          ? GestureDetector(
              onDoubleTap: onDoubleTap,
              onTap: onTap,
              onLongPress: onLongPress,
              onSecondaryTap: onSecondaryTap,
              onSecondaryLongPress: onSecondaryLongPress,
              onHorizontalDragUpdate: onHorizontalDragUpdate,
              onVerticalDragUpdate: onVerticalDragUpdate,
              onScaleUpdate: onScaleUpdate,
              child: CircleAvatar(
                backgroundColor: borderColor,
                radius: efectiveRadius,
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: circleColor,
                  backgroundImage: _getImageProvider(),
                  child: child,
                ),
              ),
            )
          : CircleAvatar(
              backgroundColor: borderColor,
              radius: efectiveRadius,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: circleColor,
                backgroundImage: _getImageProvider(),
                child: child,
              ),
            ),
    );
  }
}

class Info1 extends StatelessWidget {
  final bool isV;
  final int lLine;
  final int vLine;
  final String label;
  final Color lColor;
  final double lSize;
  final String value;
  final Color vColor;
  final double vSize;
  final VoidCallback? lTap;
  final VoidCallback? vTap;
  final List<TextSpan>? lSpan;
  final List<TextSpan>? vSpan;
  final bool lBold;
  final bool vBold;
  final double height;
  const Info1({
    super.key,
    this.isV = false,
    this.label = '',
    this.lColor = Colors.black54,
    this.lSize = 12,
    this.lTap,
    this.lLine = 1,
    this.value = '',
    this.vColor = Colors.black87,
    this.vSize = 12,
    this.vTap,
    this.vLine = 1,
    this.lSpan,
    this.vSpan,
    this.lBold = false,
    this.vBold = false,
    this.height = 4
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isV
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: lTap,
                    child: RichText(
                      text: TextSpan(
                        text: label,
                        style: TextStyle(
                          color: lColor,
                          fontSize: lSize,
                          fontWeight: lBold ? FontWeight.bold : null,
                        ),
                        children: lSpan,
                      ),
                      maxLines: lLine,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(height: height),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: vTap,
                    child: RichText(
                      text: TextSpan(
                        text: value,
                        style: TextStyle(
                          color: vColor,
                          fontSize: vSize,
                          fontWeight: vBold ? FontWeight.bold : null,
                        ),
                        children: vSpan,
                      ),
                      maxLines: vLine,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: lTap,
                    child: Text(
                      textAlign: TextAlign.left,
                      label,
                      style: TextStyle(
                        color: lColor,
                        fontSize: lSize,
                        fontWeight: lBold ? FontWeight.bold : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: vTap,
                    child: Text(
                      textAlign: TextAlign.right,
                      value,
                      style: TextStyle(
                        color: vColor,
                        fontSize: vSize,
                        fontWeight: vBold ? FontWeight.bold : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class Info2 extends StatelessWidget {
  final int line;
  final String text;
  final Color color;
  final double size;
  final bool bold;
  final bool right;
  const Info2({
    super.key,
    this.text = "",
    this.line = 1,
    this.color = Colors.black,
    this.bold = true,
    this.size = 10,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: right ? TextAlign.right : null,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : null,
      ),
      maxLines: line,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class Grid1 extends StatelessWidget {
  final int column;
  final List<Widget>? childs;
  const Grid1({super.key, this.childs = const [], this.column = 1});

  @override
  Widget build(BuildContext context) {
    final double maxSize = MediaQuery.of(context).size.width;
    final bool desk = maxSize > 900 ? true : false;
    final bool tabl = (maxSize <= 900 && maxSize > 600) ? true : false;
    return GridView.count(
      crossAxisCount: desk
          ? column * 3
          : tabl
          ? column * 2
          : column * 1,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: const EdgeInsets.all(10),
      children: childs!,
    );
  }
}

class Grid2 extends StatelessWidget {
  final int column;
  final List<Widget>? childs;
  const Grid2({super.key, this.childs = const [], this.column = 1});

  @override
  Widget build(BuildContext context) {
    final double maxSize = MediaQuery.of(context).size.width;
    final bool desk = maxSize > 900 ? true : false;
    final bool tabl = (maxSize <= 900 && maxSize > 600) ? true : false;
    return GridView.builder(
      itemCount: childs!.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desk
            ? column * 3
            : tabl
            ? column * 2
            : column * 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return childs![index];
      },
    );
  }
}

class ResponsiveItem {
  final Widget widget;
  final int span;

  const ResponsiveItem({required this.widget, this.span = 1});
}

class PageLayout extends StatelessWidget {
  final List<ResponsiveItem> items;
  final double spacing;

  const PageLayout({super.key, required this.items, this.spacing = 12.0});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;

          // Ekran genişliğine göre grid kolon sayısını ve birim genişliği belirliyoruz
          int totalColumns = 1;
          if (totalWidth > 900) {
            totalColumns = 3; // Masaüstü (3 Sütunlu Izgara)
          } else if (totalWidth > 600) {
            totalColumns = 2; // Tablet (2 Sütunlu Izgara)
          } else {
            totalColumns = 1; // Mobil (Tek Sütun)
          }

          // Toplam boşlukları hesaba katarak 1 kolonun net genişliğini buluyoruz
          final double singleColumnWidth =
              (totalWidth - (spacing * (totalColumns + 1))) / totalColumns;

          return SingleChildScrollView(
            padding: EdgeInsets.all(spacing),
            child: Wrap(
              spacing: spacing, // Yatay boşluk
              runSpacing: spacing, // Dikey boşluk (Satır arası)
              children: items.map((item) {
                // Elemanın span değerine göre genişlik hesabı yapılıyor
                // Eğer ekranın toplam kolon sayısından büyük bir span istenirse (örneğin mobilde 2 veya 3 span)
                // mevcuttaki maks kolona yuvarlanır.
                int effectiveSpan = item.span > totalColumns
                    ? totalColumns
                    : item.span;

                double itemWidth;
                if (effectiveSpan == 1) {
                  itemWidth = singleColumnWidth;
                } else if (effectiveSpan == 2) {
                  // 2 Kolon Genişliği + aradaki 1 adet boşluk
                  itemWidth = (singleColumnWidth * 2) + spacing;
                } else {
                  // 3 Kolon veya Full Width (Ekranın Tam Genişliği)
                  itemWidth = totalWidth - (spacing * 2);
                }

                return SizedBox(width: itemWidth, child: item.widget);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}



//----------------------------------------------------------------
//   Ortak Modeller tum Sayfalarda kullanilacak

class KartBackground {
  final Color? solidColor;
  final List<Color>? gradientColors;
  final String? imageAsset;

  const KartBackground.solid(this.solidColor)
    : gradientColors = null,
      imageAsset = null;

  KartBackground.gradient(Color start, Color end)
    : solidColor = null,
      gradientColors = [start, end],
      imageAsset = null;

  const KartBackground.image(this.imageAsset)
    : solidColor = null,
      gradientColors = null;
}

class KartLogo {
  final Color? color;
  final String? imageAsset;

  const KartLogo.color(this.color) : imageAsset = null;
  const KartLogo.image(this.imageAsset) : color = null;
}