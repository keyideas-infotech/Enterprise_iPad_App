//
//  OfflineSync.h
//  RST Builders
//
//  Created by keyideasmac4 on 3/18/14.
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ASIFormDataRequest.h"
#import "leadMeasurementInfotab2.h"
#import "paymentInfo.h"

@class AppDelegate;
@class customerDetails;
@protocol OffsyncDelegate;

@interface OfflineSync : NSObject
{
    
    
    
     ASIFormDataRequest *request_lead;
     ASIFormDataRequest *request_measurment;
     ASIFormDataRequest *request_check_list;
     ASIFormDataRequest *request_issue_list;
     ASIFormDataRequest *request_payment;
     ASIFormDataRequest *request_delete;
     __unsafe_unretained id <OffsyncDelegate> delegate;
     NSString * databasePath;
     customerDetails *cust_detail ;
     NSString *customer_id_for_lead;
     leadMeasurementInfotab2 *leadMeasObj, *leadMeasObj2,*current_leasd_meas;
     NSMutableDictionary *formoneDict;
     int value33;
     NSMutableArray  *webMeasureIdArr;
    
     NSMutableArray *off_total_lead;
     NSMutableArray *off_total_measurment;
     NSInteger lead_current_index;
     NSInteger measurment_current_index;
    
     NSMutableArray *total_off_check_list;
     NSMutableArray *total_off_esttime_list;
     NSMutableArray *total_off_speacins_list;
     NSString *off_str_check_list;
     NSString *off_str_esttime_list;
     NSString *off_str_speacins_list;
     NSMutableArray *total_local_lead_check;
     NSInteger check_current_index;
    
     NSInteger current_issue_index;
     NSMutableArray *off_issue_arr;
     NSMutableArray *off_total_issue_meas;
     paymentInfo *pay_info;
    
     NSInteger current_payment_index;
     NSMutableArray *total_off_payment;
    
     NSInteger current_deleted_index;
     NSMutableArray *total_off_deleted;
    
    
}



@property (assign) id <OffsyncDelegate> delegate;
-(void)offsyncStarted;
@property(nonatomic,strong) ASIFormDataRequest *request_lead;
@property(nonatomic,strong) ASIFormDataRequest *request_measurment;
@property(nonatomic,strong) ASIFormDataRequest *request_check_list;
@property(nonatomic,strong) ASIFormDataRequest *request_issue_list;
@property(nonatomic,strong) ASIFormDataRequest *request_payment;
@property(nonatomic,strong) ASIFormDataRequest *request_delete;

@property(nonatomic,strong) NSMutableDictionary *formoneDict;
@property(nonatomic,strong) NSMutableArray  *webMeasureIdArr;
@property(nonatomic,strong) NSMutableArray *off_total_lead;
@property(nonatomic,strong) NSMutableArray *off_total_measurment;
@property(nonatomic,strong) NSMutableArray *total_off_check_list;
@property(nonatomic,strong) NSMutableArray *total_off_esttime_list;
@property(nonatomic,strong) NSMutableArray *total_off_speacins_list;
@property(nonatomic,strong) NSString *off_str_check_list;
@property(nonatomic,strong) NSString *off_str_esttime_list;
@property(nonatomic,strong) NSString *off_str_speacins_list;
@property(nonatomic,strong) NSMutableArray *total_local_lead_check;
@property(nonatomic,strong) NSMutableArray *off_issue_arr;
@property(nonatomic,strong) NSMutableArray *off_total_issue_meas;
@property(nonatomic,strong) NSMutableArray *total_off_payment;
@property(nonatomic,strong) NSMutableArray *total_off_deleted;
@end

@protocol OffsyncDelegate

- (void)OffsyncFinished;
- (void)OffsyncFail;

@end