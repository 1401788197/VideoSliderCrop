#define kColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kColorFromRGBAlpha(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

#define Kfont(size) [UIFont systemFontOfSize:size]

#define Kboldfont(size) [UIFont boldSystemFontOfSize:size]

#define KMaxY(view) CGRectGetMaxY(view.frame)

#define KMaxX(view) CGRectGetMaxX(view.frame)


#define KMixY(view) CGRectGetMinY(view.frame)

#define KMixX(view) CGRectGetMinX(view.frame)
