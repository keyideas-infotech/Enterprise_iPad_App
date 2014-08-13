//
//  treatmentType.h
//  Measurements
//
//  Created by User on 07/02/13.
//
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import <UIKit/UIKit.h>
#import "WSAssetPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "sqlite3.h"
#import "customerDetails.h"
#import "customerInformation.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>
#import "NoteView.h"
#import "SmoothLineView.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "leadMeasurementInfo.h"
#import "dbClassRef.h"
#import "MBProgressHUD.h"
#import "OverlayViewController.h"

@class AppDelegate;
@class SmoothLineView;
@interface treatmentType : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WSAssetPickerControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate,UIAlertViewDelegate>{
    NSString * databasePath;
    sqlite3 * database ;
    IBOutlet UITableView *optionTable;
    UIViewController *controller;
    UIViewController *controller2;
    UIPopoverController *popOver;
    UIPopoverController *popOver2;
    NSArray *labelArr, *labelArr_tab2;
    NSString *insertSQL;
    UIView *viewforNote;
    NSString *mID;
    NoteView *note;
    UITextField *txtF;
    NSArray *webMeasureIdArr;
    SmoothLineView *viewforsketch;
    NSString *controlPositionStr,*controlType, *rollTypeStr, *extensionBracketStr, *oldTreatmentStr, *typeStr, *cordtypeStr, *headrailStr, *tdbuStr, *mounttype2, *spacerneededStr, *mountTypeStr,*cordSideStr, *pairSingleStr,*cielingtofloorStr, *functionalityStr, *systemStr, *liningStr;
    NSMutableArray *nullmeasurementid, *imageDataArr, *imageDataArr_tab2, *imageUrlArr, *imageNameArr;
    NSMutableArray *imageDataArr_edit, *imageDataArr_tab2_edit,*sketch_imagedataArr_tab1,*sketch_imagedataArr_tab2;
    NSString *webmsmtID, *leadID;
    int val;
    int index, index_tab2;
    NSString *noteText, *installation_note_text;
    NSString *noteText_tab2, *installation_note_text_tab2;
    BOOL dbupdateFlage;
    NSArray *form_oneArr, *formtwoArr;
    BOOL formtypeFlag;
    UIButton *noneBtn, *uphBtn, *uphoptionBtn, *mvalanceBtn;
    BOOL noneFlag, uphFlag, uphOtionBtnoneFlag,uphOtionBtntwoFlag,uphOtionBtnthreeFlag, mvalanceFlag, mvOtionBtnoneFlag,mvOtionBtntwoFlag,mvOtionBtnthreeFlag;
    UIView *optionView;
    UILabel *oneLbl,*Lbltwo, *Lblthree, *UILabel, *mvalanceLbl;
    NSMutableArray *tfoptionalFeatureArr;
    NSString *imagetoserver;
    NSData *imagedata, *sketchImageData_tab1, *sketchImageData_tab2;
    NSString *specStr;
    int currenttabFlag;
    int row;
    int col;
    int row_tab2;
    int col_tab2;
    NSString *product_namefor_tab1, *product_namefor_tab2;
    NSMutableArray *tabone_Arr;
    NSMutableArray *tabtwo_Arr;
    
    NSMutableDictionary *formoneDict;
    NSMutableDictionary *formtwoDict;
    BOOL tab2flag, tab1flag;
    int gotonextView, gotonextView_tab2;
    int alert1, alert2;
    NSString *formTypeValue;
    int max;
    int labelArrtab2_count;
    IBOutlet UILabel *cust_nameLbl, *cust_addrLbl, *cust_emailLbl, *cust_phoneLbl, *manu_nameLbl, *dateLbl, *lead_hashLbl;
    IBOutlet UILabel *cust_nameSemi, *cust_addrSemi, *cust_emailSemi, *cust_phoneSemi, *manu_nameSemi, *dateSemi, *lead_hashSemi;
    BOOL str;
    IBOutlet UIButton *submitBtn, *view_inst_imageBtn;
    int indexforsketch,indexforsketch2;
    BOOL tab1ClickedFlag,tab2ClickedFlag;
    UIImageView* imgView;
    NSString *windowSideMarkText, *materialText, *pairorsingleText, *left_f_text, *left_i_text, *width_f_text, *width_i_text, *right_f_text, *right_i_text, *total_width_f_text, *total_width_i_text, *hardware_width_text, *top_f_text, *top_i_text, *height_f_text, *height_i_text,*total_height_f_text, *total_height_i_text, *topofpole_text, *ceilingtofloor_text;
    NSString *width_f_form1_text,*width_i_form1_text, *height_f_form1_text,*height_i_form1_text, *depth_f_form1_text,*depth_i_form1_text,*left_f_form1_text,*left_i_form1_text,*right_f_form1_text, *right_i_form1_text, *bracket_f_form1_text, *bracket_i_form1_text, *total_width_f_form1_text,*total_width_i_form1_text, *top_f_form1_text, *top_i_form1_text,*bottom_f_form1_text,*bottom_i_form1_text, *total_height_f_form1_text, *total_height_i_form1_text;
    BOOL textF_touch_flag_tab1, textF_touch_flag_tab2;
    IBOutlet UIScrollView *detail_scrollView;
    BOOL imageSource_selected_in_edit_form1,imageSource_selected_in_edit_form2;
    UILabel *sketch_text_lbl, *sketch_text_lbl_form2;
    NSString *form_1_productID, *form_2_productID, *roomLabelValue1,*roomLabelValue2;
    NSString *optionalFeaturesStr,*optionalFeaturesStrForTextField;
    UIImageView *img;
    NSArray *valuesArr,*valuesArr2,*valuesArr3;
    NSString *left_inch,*width_inch,*right_inch;
    NSString *topInch,*heightInch;
    NSString *poleTopFt,*poleTopInch,*poleHeightFt,*poleHeightInch;
    NSArray *valueArr1,*valueArr2;
    NSString *left_inch_form1,*width_inch_form1,*right_inch_form1,*bracket_inch_form1;
    NSArray *valuesArr_form1,*valuesArr2_form1,*valuesArr3_form1,*valuesArr4_form1;
    NSString *top_inch,*height_inch,*bottom_inch;
    NSArray *valueArr_form1,*valueArr2_form1,*valueArr3_form1;
    UIImageView* imgView2;
    UILabel *picLbl,*picLbl_tab2,*sketchLbl,*sketchLbl_tab2;
    CGPoint svos;
    
    
     UITextField *txt_left_ft;
     UITextField *txt_left_inch;
     UITextField *txt_center_ft;
     UITextField *txt_center_inch;
     UITextField *txt_right_ft;
     UITextField *txt_right_inch;
     NSInteger room_lable_type_status;
     NSArray *room_label_arr;
    
     UITextField *txt_hard_inch;
     UITextField *txt_bottum_inch;
     UITextField *txt_puddle_inch;
     UITextField *txt_return_inch;
     UITextField *txt_offthefloor_inch;
     UITextField *txt_finished_inch;
    
     NSInteger firstselection;
     NSInteger secondselection;
     NSInteger firstchoose;
     NSInteger secondchoose;
     NSInteger send_success;
     NSInteger tab1valid_success;
     NSInteger tab2valid_success;
     UIScrollView *scrollView_forpresetsketch;
    
     //added 11 march
     UIScrollView *scrollView_forpresetsketch_tab2;
     UILabel *preset_sketchLbl,*preset_sketchLbl_tab2;
     MBProgressHUD * hud ;
     NSInteger imgdupload_status;
     NSInteger conalert_status;
     NSInteger netwrok_fail;
    OverlayViewController *ovController;
    IBOutlet UIButton *bar_btn;
    
   
}
@property (nonatomic)int formNumberClicked;
@property (nonatomic, retain)UIPopoverController *popOver;
@property (nonatomic, retain) NoteView *note;
- (IBAction)submitClicked:(id)sender;
- (IBAction)view_inst_imageBtnClicked:(id)sender;
@property (nonatomic, strong)IBOutlet UIView *view1;
@property (nonatomic, strong) WSAssetPickerController *pickerController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView_forsketch;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView_forsketch_tab2;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView_tab2;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, readwrite) BOOL pageControlInUse;
@property (strong, nonatomic) IBOutlet UIButton *addOptionBtn;
@property (strong, nonatomic) NSString * selectedTreatmentType;
@property (strong, nonatomic) NSString * selectedTreatmentType_two;
@property (strong, nonatomic) IBOutlet NSString *strLocalLeadID;
@property (strong, nonatomic) IBOutlet NSString *strLocalMeasurementLeadID;
@property (strong, nonatomic) IBOutlet UITableView *optionTable;
@property (strong, atomic) ALAssetsLibrary* library;
@property (strong, nonatomic) IBOutlet UILabel *custName;
@property (strong, nonatomic) IBOutlet UILabel *custAdd;
@property (strong, nonatomic) IBOutlet UILabel *custEmail;
@property (strong, nonatomic) IBOutlet UILabel *custPhone;
@property (strong, nonatomic) IBOutlet UILabel *techName;
@property (strong, nonatomic) IBOutlet UILabel *techPhone;
@property (strong, nonatomic) IBOutlet UILabel *salesPerson;
@property (strong, nonatomic) IBOutlet UILabel *productNameLbl;

@property (strong, nonatomic) IBOutlet UITextField *txfdRoomLabel;
@property (strong, nonatomic) IBOutlet UITextField *txfdTreatment;
@property (strong, nonatomic) IBOutlet UITextField *txfdlayer;
@property (strong, nonatomic) IBOutlet UITextField *txfdMaterial;
@property (strong, nonatomic) IBOutlet UITextField *txfdRolltype;
@property (strong, nonatomic) IBOutlet UITextField *txfdExtensionB;
@property (strong, nonatomic) IBOutlet UITextField *txfdOldtreatment;
@property (strong, nonatomic) IBOutlet UITextField *txfdMounttype;
@property (strong, nonatomic) IBOutlet UITextField *txfdHeight;
@property (strong, nonatomic) IBOutlet UITextField *txfdWidth;
@property (strong, nonatomic) IBOutlet UITextField *txfdDepth;
@property (strong, nonatomic) IBOutlet UITextField *txfdHeight_inch;
@property (strong, nonatomic) IBOutlet UITextField *txfdWidth_inch;
@property (strong, nonatomic) IBOutlet UITextField *txfdDepth_inch;
@property (strong, nonatomic) IBOutlet UITextField *txfdQuality;
@property (strong, nonatomic) IBOutlet UITextField *txfdControlPosition;
@property (strong, nonatomic) IBOutlet UITextField *txfdOptionalFeature;
@property (strong, nonatomic) IBOutlet UIView *viewforMounttypeOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdleftOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdwidthOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdrightOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdbracketOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdtotalwidthOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdtopOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdheightOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdbottomOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdtotalheightOM;
@property (retain, nonatomic) IBOutlet UITextField *txfdleftOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdwidthOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdrightOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdbracketOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdtopOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdheightOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txfdbottomOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txftotalWidthOM_ft;
@property (retain, nonatomic) IBOutlet UITextField *txftotalWidthOM_inch;
@property (retain, nonatomic) IBOutlet UITextField *txftotalHeightOM_ft;
@property (retain, nonatomic) IBOutlet UITextField *txftotalHeightOM_inch;
@property (strong, nonatomic) IBOutlet UITextField *productnameTF;
@property (strong, nonatomic) IBOutlet UITextField *productnameTF_tab2;
@property (strong, nonatomic) IBOutlet UIButton *form_oneBtn;
@property (strong, nonatomic) IBOutlet UIButton *form_twoBtn;

@property (strong, nonatomic) UIView *viewforControlls;
@property (strong, nonatomic) UIScrollView *scrollFortab1;
@property (strong, nonatomic) UIScrollView *scrollFortab2;
@property (strong, nonatomic) UIView *viewfortabtwo_Controlls;
@property (strong, nonatomic) IBOutlet UILabel *navigationTitle;
@property (strong, nonatomic) AppDelegate *appdelObj;
@property (strong, nonatomic) NSString *modeValue;



@property (strong, nonatomic) UITextField *txt_left_ft;
@property (strong, nonatomic) UITextField *txt_left_inch;
@property (strong, nonatomic) UITextField *txt_center_ft;
@property (strong, nonatomic) UITextField *txt_center_inch;
@property (strong, nonatomic) UITextField *txt_right_ft;
@property (strong, nonatomic) UITextField *txt_right_inch;
//added 11 march
@property (strong, nonatomic) UIScrollView *scrollView_forpresetsketch_tab2;
@property (strong, nonatomic) UIScrollView *scrollView_forpresetsketch;

- (IBAction)addOptionBtnClicked:(id)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)infobtnPressed:(id)sender;
- (IBAction)form_onePressed:(id)sender;
- (IBAction)form_twoPressed:(id)sender;
-(BOOL)uploadImage:(UIImage *)image withName:(NSString *)fileName toURL:(NSURL *)url;
-(NSString *)getInchesValues:(NSString *)str1;

@end
