//
//  FrameViewController.m
//  DecoCamera
//
//  Created by 池田享浩 on 2015/12/26.
//  Copyright © 2015年 takahiro ikeda. All rights reserved.
//

#import "FrameViewController.h"
#import "ImageViewController.h"

@interface FrameViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

//delegateとは、あるインスタンスから他のインスタンスに通知を送る機能。
//UIImagePickerは、モーダルでの遷移込みのため、UINavigationControllerDelegate,UIImagePickerControllerDelegateを使う。
//UICollectionView データ管理を行うUICollectionViewDataSourceを使う。

@property (weak,nonatomic)IBOutlet UICollectionView *frameCollectionView;

@property (strong,nonatomic) NSArray *frameArray;
@property (strong,nonatomic) UIImage *editImage;

@end

@implementation FrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.frameArray = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16];
    //self.collectionView.delegate = self;
    //self.collectionView.dataSource = self;
    //＝selfとは、動作は、自分の中にある。StoryBoardからもできる。
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.frameArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //CollectionView上のUIImageViewをタグを用いて取得
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    NSString *imgName = [NSString stringWithFormat:@"frame_%02ld.png",(long)[self.frameArray[indexPath.row] integerValue]];
    
    UIImage *image = [UIImage imageNamed:imgName];
    imageView.image = image;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //カメラが使用できるかどうか判定。
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        //カメラを生成
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        //デリゲートを自分自身に設定
        imagePickerController.delegate = self;
        //写真モードを選ぶ。（映像モードもある）
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = YES;
        
        
        //ずれ防止 テキスト50を0にかえると　y方向に調整できる。
        imagePickerController.cameraViewTransform = CGAffineTransformTranslate(imagePickerController.cameraViewTransform,0,50);
        
        //UIImagePickerControllerは縦長限定になるので、正方形にするため、画面を隠す。
        CGRect rect = imagePickerController.view.bounds;
        
        //試し
        //CGRect cr = [[UIScreen mainScreen] bounds];
        //CGRect rect = [[UIScreen mainScreen] bounds];
        
        NSLog(@"イメージピッカーのサイズ %lf",rect.size.height);//画面サイズ
        //NSLog(@"画面全体サイズ %lf",cr.size.height);//画面サイズ

        rect.size.height -= imagePickerController.navigationBar.bounds.size.height;
        
        NSLog(@"ナビゲーションコントローラの高さ %lf",imagePickerController.navigationBar.bounds.size.height);//画面サイズ
        
        CGFloat barHeight = (rect.size.height - rect.size.width)/2;
        UIGraphicsBeginImageContext(rect.size);
        [[UIColor colorWithWhite:0 alpha:1]set];
        UIRectFillUsingBlendMode(CGRectMake(0,0,rect.size.width,barHeight),kCGBlendModeNormal);//kCGBlendModeNormal調査済み
        UIRectFillUsingBlendMode(CGRectMake(0,rect.size.height - barHeight,rect.size.width,barHeight/1.48), kCGBlendModeNormal);//barHeight 縮小割合　テキスト　1.48
        UIImage *rimImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSLog(@"rect.size.height2 %lf",rect.size.height);
        NSLog(@"rect.size.width %lf",rect.size.width);
        NSLog(@"barHieght %lf",barHeight);
        
        
        
        //画面上にフレームなどを置くための土台を作る。
        UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0,0,rect.size.width,rect.size.height)];
        
        //画面を隠す部分を準備。
        UIImageView *rimView = [[UIImageView alloc] initWithFrame:rect];
        rimView.image = rimImage;
        [baseView addSubview:rimView];
        
        //フレームを準備
        NSString * imgName = [NSString stringWithFormat:@"frame_%02ld.png",(long)[self.frameArray[indexPath.row] integerValue]];
        UIImageView *frameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        frameView.frame = (CGRect){0,barHeight, rect.size.width, rect.size.width};
        [baseView addSubview:frameView];
        
        //画面上にフレームなどを置く。
        [imagePickerController setCameraOverlayView:baseView];
        
        //モーダルビューとしてカメラ画面を呼び出す。
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //カメラ(UIImagePickerController)を閉じる。
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //浮世絵フレームと写真は別になっているから合成が必要
    //キャプチャー対象をWindowにする。
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //これからキャプチャするための作業場所を生成
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //１つ１つのwindowの現在の表示内容を作業場所に描画していく。
    for(UIWindow *aWindow in [UIApplication sharedApplication].windows){
        [aWindow.layer renderInContext:context];
    }
    
    //作業場所に描画した内容をUIImageとして受け取る。
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //作業場所を廃棄する。
    UIGraphicsEndImageContext();
    
    //window全体だと不要な部分があるから、浮世絵フレームを含めた写真を部分だけ切り抜く。
    CGRect rect = picker.view.bounds;
    rect.size.height -=picker.navigationBar.bounds.size.height;
    CGFloat barHeight = (rect.size.height - rect.size.width)/2;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width,rect.size.width));
    
    //画像を描画する。
    [capturedImage drawAtPoint:CGPointMake(0,-barHeight)];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //描画終了
    UIGraphicsEndImageContext();
    
    self.editImage = capturedImage;
    [self performSegueWithIdentifier:@"ImageView" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"ImageView"]){
        
        ImageViewController *nextViewController = [segue destinationViewController];
        nextViewController.editImage = self.editImage;
    }
}

@end
