//
//  ImageViewController.m
//  DecoCamera
//
//  Created by 池田享浩 on 2015/12/26.
//  Copyright © 2015年 takahiro ikeda. All rights reserved.
//

#import "ImageViewController.h"
@interface ImageViewController()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property(weak,nonatomic) IBOutlet UIButton *grayButton;
@property(assign,nonatomic ) BOOL isGray;

-(IBAction)saveButtonAction:(id)sender;
-(IBAction)grayButtonAction:(id)sender;
-(IBAction)backButtonAction:(id)sender;

//課題内容追加
@property(weak,nonatomic)IBOutlet UISlider *Slider;
@property(weak,nonatomic) IBOutlet UIButton *largeButton;
@property(weak,nonatomic) IBOutlet UIButton *smallButton;
@property(weak,nonatomic) IBOutlet UILabel *brightnessLabel;
@property (weak, nonatomic) IBOutlet UIImageView *background;

-(IBAction)largeButtonAction:(id)sender;
-(IBAction)smallButtonAction:(id)sender;
-(IBAction)SlideAction:(id)sender;
-(IBAction)defaultButton:(id)sender;

@property(assign,nonatomic ) BOOL isLarge;
@property(assign,nonatomic ) BOOL isSmall;
@property (assign, nonatomic) CGFloat centerx;
@property (assign, nonatomic) CGFloat centery;
@property (assign, nonatomic) CGFloat imagewidth;
@property (assign, nonatomic) CGFloat imageheight;
@property (strong, nonatomic) UIImage *grayScaleImage;
@property (strong, nonatomic) NSString *atai;


@end

@implementation ImageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.image = self.editImage;
    self.isGray = NO;
    
    self.isLarge = NO;
    self.isSmall = NO;
    
    CGFloat a = self.imageView.center.x;
    CGFloat b = self.imageView.center.y;
    CGFloat c = self.editImage.size.width;
    CGFloat d = self.editImage.size.height;
    
    
    NSLog(@"imageViewの中心x座標 %f",(CGFloat)a);
    NSLog(@"imageViewの中心y座標 %f",(CGFloat)b);
    NSLog(@"editImageの幅 %f",(CGFloat)c);
    NSLog(@"editImageの高さ %f",(CGFloat)d);
    
    
    self.centerx = a;
    self.centery = b;
    self.imagewidth = c;
    self.imageheight = d;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)saveButtonAction:(id)sender {
    
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    
   // UIImageWriteToSavedPhotosAlbum(self.imageView.image,self, selector, NULL);
    
    
    if(self.isSmall || self.isLarge){
        
            //全画面キャプチャ
            self.background.image = [UIImage imageNamed:@"whitegazo.png"];
        
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
            // キャプチャ画像を描画する対象を生成します。
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
        
            // Windowの現在の表示内容を１つずつ描画して行きます。
            for (UIWindow *aWindow in [[UIApplication sharedApplication] windows]) {
                [aWindow.layer renderInContext:context];
            }
        
            // 描画した内容をUIImageとして受け取ります。
            UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        
            // 描画を終了します。
            UIGraphicsEndImageContext();
        
        
        
            //切り取り
            // 切り取る枠を指定
            CGRect rect = CGRectMake(self.centerx - self.imagewidth/2,self.centery - self.imageheight/2,self.imagewidth ,self.imageheight);
            UIImage*  createdImage = [self partialImageOfRect:capturedImage size:rect];
        
            UIImageWriteToSavedPhotosAlbum(createdImage ,self, selector, NULL);
        
            self.background.image = [UIImage imageNamed:@"background.png"];
        

        } else {
        
            UIImageWriteToSavedPhotosAlbum(self.imageView.image,self, selector, NULL);
      
        }
    
}


//画像保存完了時のセレクタ
-(void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"保存終了" message:@"画像を保存しました" preferredStyle:UIAlertControllerStyleAlert] ;
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)grayButtonAction:(id)sender{
    
    self.isGray = !self.isGray;
    //　BOOL = !BOOL ビットの反転
    
    self.Slider.value = 0;
    self.atai = [NSString stringWithFormat:@"明るさ:%.2f",self.Slider.value];
    self.brightnessLabel.text = self.atai;
    
    if(self.isGray){
        
        [self.grayButton setTitle:@"Reset" forState:UIControlStateNormal];
        UIImage *image = self.editImage;
        CGRect imageRect = (CGRect){0.0,0.0, image.size.width,image.size.height};
        
        //CoreGraphicsのモノクロ色空間を準備します。 CGColorSpaceRefは、構造体 カラースペースを管理する構造体
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        //ビットマップコンテキストを作りサイズと色空間を設定する　CGContextRefは、構造体 描画に必要な情報などを管理する構造体
        CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height,8,0,colorSpace,kCGImageAlphaNone);
        
        //ビットマップコンテキストに画像を描画する。
        CGContextDrawImage(context,imageRect,[image CGImage]);
        
        //ビットマップコンテキストに描画された画像を取得
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        //取得した画像からUIImageを作る。
        //UIImage *grayScaleImage = [UIImage imageWithCGImage:imageRef];
        self.grayScaleImage = [UIImage imageWithCGImage:imageRef];
        
        //準備した色空間、ビットマップコンテキスト、取得した画像をメモリから解放
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CFRelease(imageRef);
        
        //Storyboard上のUIImageViewに画像を描画する
        self.imageView.image = self.grayScaleImage;
    }else{
        self.grayButton.titleLabel.text = @"Gray";
        [self.grayButton setTitle:@"Gray" forState:UIControlStateNormal];
        
        self.imageView.image = self.editImage;
    }
    
}

//課題　拡大
-(IBAction)largeButtonAction:(id)sender{
    
    self.isLarge = !self.isLarge;
    //　BOOL = !BOOL ビットの反転

    
    /* イメージ自体の拡大
    UIImage *aImage = self.imageView.image;  // imageViewはUIImageView型のフィールド変数。
    
    // 画像を縮尺
    UIImage *resizedImage = [self resizeImage:aImage scale:2.0f];
    
    // 縮小した画像をUIImageViewの画像として登録する
    self.imageView.image = resizedImage;
     */

    
    //　imageViewのサイズを変える
    if(self.isLarge){
        [self.largeButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self.smallButton setTitle:@"縮小" forState:UIControlStateNormal];
        self.isSmall = NO;
        CGFloat xScale = 3.0f; // x軸方向に1.5倍
        CGFloat yScale = 3.0f; // y軸方向に1.5倍
        self.imageView.transform = CGAffineTransformMakeScale(xScale, yScale);
    } else {
        [self.largeButton setTitle:@"拡大" forState:UIControlStateNormal];
        CGFloat xScale = 1.0f; // x軸方向に1倍
        CGFloat yScale = 1.0f; // y軸方向に1倍
        self.imageView.transform = CGAffineTransformMakeScale(xScale, yScale);

    }
    /*拡大時の位置確認
    CGFloat la = self.imageView.center.x;
    CGFloat lb = self.imageView.center.y;
    CGFloat lc = self.imageView.image.size.width;
    CGFloat ld = self.imageView.image.size.height;
    
    
    NSLog(@"imageViewの中心x座標 %f",(CGFloat)la);
    NSLog(@"imageViewの中心y座標 %f",(CGFloat)lb);
    NSLog(@"拡大後のイメージの幅 %f",(CGFloat)lc);
    NSLog(@"拡大後のイメージの高さ %f",(CGFloat)ld);
    */
    
    }
//課題　縮小
-(IBAction)smallButtonAction:(id)sender{
    
    self.isSmall = !self.isSmall;
    //　BOOL = !BOOL ビットの反転
    
    /* image自体のファイルを変える
    UIImage *aImage = self.imageView.image;  // imageViewはUIImageView型のフィールド変数。
    
    // 画像を縮尺1
    UIImage *resizedImage = [self resizeImage:aImage scale:0.5f];
    
    // 縮小した画像をUIImageViewの画像として登録する
    self.imageView.image = resizedImage;
    */
     
    // imageViewのサイズを変える
    if(self.isSmall){
        [self.smallButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self.largeButton setTitle:@"拡大" forState:UIControlStateNormal];
        self.isLarge = NO;
        CGFloat xScale = 0.5f; // x軸方向に0.5倍
        CGFloat yScale = 0.5f; // y軸方向に0.5倍
        self.imageView.transform = CGAffineTransformMakeScale(xScale, yScale);
    } else {
        [self.smallButton setTitle:@"縮小" forState:UIControlStateNormal];
        CGFloat xScale = 1.0f; // x軸方向に1倍
        CGFloat yScale = 1.0f; // y軸方向に1倍
        self.imageView.transform = CGAffineTransformMakeScale(xScale, yScale);
    }
    
    /*画像位置の確認を行った
    
    CGFloat sa = self.imageView.center.x;
    CGFloat sb = self.imageView.center.y;
    CGFloat sc = self.imageView.image.size.width;
    CGFloat sd = self.imageView.image.size.height;
    
    
    NSLog(@"imageViewの中心x座標 %f",(CGFloat)sa);
    NSLog(@"imageViewの中心y座標 %f",(CGFloat)sb);
    NSLog(@"縮小後のイメージの幅 %f",(CGFloat)sc);
    NSLog(@"縮小後のイメージの高さ %f",(CGFloat)sd);
    */
    
    }

/* イメージ自体のサイズを変える時のメソッド
- (UIImage*)resizeImage:(UIImage *)img scale:(float)scale {
    
    // 指定されたスケールから、画像のリサイズ後のサイズを計算する
    CGSize resizedSize = CGSizeMake(img.size.width * scale, img.size.height * scale);
    
    // UIGraphics××の関数を利用して、画像をリサイズする   ←ここが重要な部分！！！
    UIGraphicsBeginImageContext(resizedSize);
    [img drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // リサイズ後の画像を呼び出し元に返す
    return resizedImage;
}
*/

//課題　スライダーによる明るさ調整
-(IBAction)SlideAction:(id)sender{
    
    if(self.isGray){
            self.atai = [NSString stringWithFormat:@"明るさ:%.2f",self.Slider.value];
            self.brightnessLabel.text = self.atai;
        
            CIImage *ciImage = [[CIImage alloc] initWithImage: self.grayScaleImage]; //ファイル名
        
            CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorControls" //フィルター名
                                        keysAndValues:kCIInputImageKey, ciImage,
                              @"inputBrightness", [NSNumber numberWithFloat:self.Slider.value], //パラメータ
                              nil
                              ];
            CIContext *ciContext = [CIContext contextWithOptions:nil];
            CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
            UIImage *tmpImage = [UIImage imageWithCGImage:cgimg scale:1.0f orientation:UIImageOrientationUp];
            CGImageRelease(cgimg);
            self.imageView.image = tmpImage;
        
        } else{
            self.atai = [NSString stringWithFormat:@"明るさ:%.2f",self.Slider.value];
            self.brightnessLabel.text =self.atai;
            
            CIImage *ciImage = [[CIImage alloc] initWithImage:self.editImage]; //ファイル名
            
            CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorControls" //フィルター名
                                            keysAndValues:kCIInputImageKey, ciImage,
                                  @"inputBrightness", [NSNumber numberWithFloat:self.Slider.value], //パラメータ
                                  nil
                                  ];
            CIContext *ciContext = [CIContext contextWithOptions:nil];
            CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
            UIImage *tmpImage = [UIImage imageWithCGImage:cgimg scale:1.0f orientation:UIImageOrientationUp];
            CGImageRelease(cgimg);
            self.imageView.image = tmpImage;

        
    }
}


//トリミング
- (UIImage *)partialImageOfRect:(UIImage *)img size:(CGRect)rect{
    
    //CGPoint originDrawPoint = CGPointMake(rect.origin.x, rect.origin.y);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    UIGraphicsBeginImageContext(rect.size);
    [img drawAtPoint:CGPointMake(0,self.imageheight/2 - self.centery)];
    UIImage* partialImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return partialImage;
}

-(IBAction)defaultButton:(id)sender{
    
    self.isGray = NO;
    self.isLarge = NO;
    self.isSmall = NO;
    
    self.imageView.image = self.editImage;
    self.Slider.value = 0;
    self.atai = [NSString stringWithFormat:@"明るさ:%.2f",self.Slider.value];
    self.brightnessLabel.text = self.atai;
    CGFloat xScale = 1.0f; // x軸方向に1倍
    CGFloat yScale = 1.0f; // y軸方向に1倍
    self.imageView.transform = CGAffineTransformMakeScale(xScale, yScale);
    
    [self.smallButton setTitle:@"縮小" forState:UIControlStateNormal];
    [self.largeButton setTitle:@"拡大" forState:UIControlStateNormal];
    [self.grayButton setTitle:@"Gray" forState:UIControlStateNormal];
    
}

-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
