//
//  OfflineSync.m
//  RST Builders
//
//  Created by keyideasmac4 on 3/18/14.
//
//

#import "OfflineSync.h"
#import "customerDetails.h"

@implementation OfflineSync

@synthesize delegate,request_lead,request_measurment,formoneDict,webMeasureIdArr,off_total_lead,off_total_measurment,total_off_check_list,total_off_esttime_list,total_off_speacins_list,off_str_check_list,off_str_esttime_list,off_str_speacins_list,total_local_lead_check,request_check_list,off_issue_arr,off_total_issue_meas,request_issue_list,request_payment,total_off_payment,total_off_deleted,request_delete;



static sqlite3 *database = nil;
-(void)offsyncStarted
{
   
    
    webMeasureIdArr =[[NSMutableArray alloc]init];
    off_total_lead =[[NSMutableArray alloc]init];
    off_total_measurment =[[NSMutableArray alloc]init];
    total_off_check_list=[[NSMutableArray alloc]init];
    total_off_esttime_list=[[NSMutableArray alloc]init];
    total_off_speacins_list=[[NSMutableArray alloc]init];
    total_local_lead_check=[[NSMutableArray alloc]init];
    off_issue_arr=[[NSMutableArray alloc]init];
    off_total_issue_meas=[[NSMutableArray alloc]init];
    total_off_payment=[[NSMutableArray alloc]init];
    total_off_deleted=[[NSMutableArray alloc]init];
    
    lead_current_index=0;
    measurment_current_index=0;
    check_current_index=0;
    current_issue_index=0;
    current_payment_index=0;
    current_deleted_index=0;
    
    [self checkAndCreateDatabase];
    [self getOfflineLead];
    
    
    
}



-(void)checkAndCreateDatabase
{
    
    
    NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir stringByAppendingPathComponent:@"keyideas_rstbuilders.sqlite"];
    BOOL success;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:databasePath];
    if (success) {
        return;
    }
    NSString * databasePathFromApp = [[NSBundle mainBundle]pathForResource:@"keyideas_rstbuilders" ofType:@"sqlite"];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    
}

-(void)getOfflineLead
{
    
    
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        
        sqlite3_stmt * compiledStatement;
        
        
        NSString *insertSQL = [NSString stringWithFormat:@"select leadHash,firstName,lastName,emailID,address,cellNumber,homeNumber,officeNumber,manufacturer,noOfWindows,windowTreatementType,manufacturerComment,salesRep,mapID,Comments,manufacturerOrderUrl,localLeadID from rst_lead where webleadID='0';"];
        
        const char *sqlStatement = [insertSQL UTF8String];
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
              
                cust_detail = [[customerDetails alloc]init];
                cust_detail.lead_hash = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 0)];
                cust_detail.nameStr = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 1)];
                cust_detail.lastName =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 2)];
                cust_detail.emailStr = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 3)];
                cust_detail.addressStr = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 4)];
                cust_detail.phoneStr =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 5)];
                cust_detail.phoneStr1=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 6)];
                cust_detail.office_phoneStr=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 7)];
                cust_detail.manufac_name=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 8)];
                cust_detail.total_window_door=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 9)];
                cust_detail.widow_treatment_type=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 10)];
                cust_detail.manuf_comnt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 11)];
                cust_detail.salesRep =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 12)];
                cust_detail.map_id=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 13)];
                cust_detail.comnt=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 14)];
                cust_detail.manuf_order_url=[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 15)];
                cust_detail.localLeadID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 16)];
                [off_total_lead addObject:cust_detail];
                
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        sqlStatement=nil;
    }
    else
    {
        sqlite3_close(database);
    }
    
    [self updateOfflineLead];

}
-(void)updateOfflineLead
{
    
    if(off_total_lead.count>lead_current_index)
    {
        
        
        [self send_request_for_customer_to_web:[off_total_lead objectAtIndex:lead_current_index]];
        
        
    }
    else
    {
        
        
        [self getOfflineMeasurment];
        
    }
    
}

-(void)getOfflineMeasurment
{
    
    [webMeasureIdArr removeAllObjects];
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"select * from rst_lead_measurement_info where webMesurementID= '0' or offlineUpdatedFlag= '1' and offlineDeletionFlag !='1';"];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
            while (sqlite3_step(compiledStatement)==SQLITE_ROW) {
                leadMeasObj = [[leadMeasurementInfotab2 alloc]init];
                leadMeasObj.leadID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 0)];
                leadMeasObj.mID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 4)];
                leadMeasObj.localMeasurementID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 3)];
                
                leadMeasObj.webMeasurementID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 2)];
                leadMeasObj.productID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 6)];
                leadMeasObj.quantity = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 73)];
                leadMeasObj.formType = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 5)];
                leadMeasObj.product = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 7)];
                leadMeasObj.mountType = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 8)];
                if ([leadMeasObj.mountType isEqualToString:@"(null)"]) {
                    leadMeasObj.mountType = @"";
                }
                leadMeasObj.rollType = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 9)];
                if ([leadMeasObj.rollType isEqualToString:@"(null)"]) {
                    leadMeasObj.rollType = @"";
                }
                leadMeasObj.material = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 10)];
                if ([leadMeasObj.material isEqualToString:@"(null)"]) {
                    leadMeasObj.material = @"";
                }
                leadMeasObj.widthFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 11)];
                if ([leadMeasObj.widthFt isEqualToString:@"(null)"]) {
                    leadMeasObj.widthFt = @"";
                }
                
                leadMeasObj.widthInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 12)];
                if([leadMeasObj.widthInch isEqualToString:@"2/8"]){
                    leadMeasObj.widthInch = @"1/4";
                }
                else if([leadMeasObj.widthInch isEqualToString:@"4/8"]){
                    leadMeasObj.widthInch = @"1/2";
                }
                else if([leadMeasObj.widthInch isEqualToString:@"6/8"]){
                    leadMeasObj.widthInch = @"3/4";
                }
                leadMeasObj.heightFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 13)];
                if ([leadMeasObj.heightFt isEqualToString:@"(null)"])
                {
                    leadMeasObj.heightFt = @"";
                }
                
                
                leadMeasObj.heightInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 14)];
                if([leadMeasObj.heightInch isEqualToString:@"2/8"])
                {
                    leadMeasObj.heightInch = @"1/4";
                }
                else if([leadMeasObj.heightInch isEqualToString:@"4/8"]){
                    leadMeasObj.heightInch = @"1/2";
                }
                else if([leadMeasObj.heightInch isEqualToString:@"6/8"]){
                    leadMeasObj.heightInch = @"3/4";
                }
                
                
                leadMeasObj.depthFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 15)];
                if ([leadMeasObj.depthFt isEqualToString:@"(null)"]) {
                    leadMeasObj.depthFt = @"";
                }
                
                
                leadMeasObj.depthInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 16)];
                if([leadMeasObj.depthInch isEqualToString:@"2/8"])
                {
                    leadMeasObj.depthInch = @"1/4";
                }
                else if([leadMeasObj.depthInch isEqualToString:@"4/8"]){
                    leadMeasObj.depthInch = @"1/2";
                }
                else if([leadMeasObj.depthInch isEqualToString:@"6/8"]){
                    leadMeasObj.depthInch = @"3/4";
                }
                
                leadMeasObj.controlPosition = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 31)];
                if ([leadMeasObj.controlPosition isEqualToString:@"(null)"]) {
                    leadMeasObj.controlPosition = @"";
                }
                leadMeasObj.totalHardwareWidth = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 29)];
                leadMeasObj.creationDate = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 75)];
                leadMeasObj.updationDate = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 76)];
                leadMeasObj.windowSidemark = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 34)];
                if ([leadMeasObj.windowSidemark isEqualToString:@"(null)"]) {
                    leadMeasObj.windowSidemark = @"";
                }
                
                leadMeasObj.laye = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 35)];
                if ([leadMeasObj.laye isEqualToString:@"(null)"]) {
                    leadMeasObj.laye = @"";
                }
                leadMeasObj.type = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 36)];
                if ([leadMeasObj.type isEqualToString:@"(null)"]) {
                    leadMeasObj.type = @"";
                }
                leadMeasObj.optionalFeatures =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 37)];
                if ([leadMeasObj.optionalFeatures isEqualToString:@"(null)"]) {
                    leadMeasObj.optionalFeatures = @"";
                }
                leadMeasObj.extentionBracket =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 38)];
                if ([leadMeasObj.extentionBracket isEqualToString:@"(null)"]) {
                    leadMeasObj.extentionBracket = @"";
                }
                leadMeasObj.mountType2 =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 39)];
                if ([leadMeasObj.mountType2 isEqualToString:@"(null)"]) {
                    leadMeasObj.mountType2 = @"";
                }
                leadMeasObj.leftFt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 19)];
                if ([leadMeasObj.leftFt isEqualToString:@"(null)"]) {
                    leadMeasObj.leftFt = @"";
                }
                
                leadMeasObj.leftInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 20)];
                
                if([leadMeasObj.leftInch isEqualToString:@"2/8"]){
                    leadMeasObj.leftInch = @"1/4";
                }
                else if([leadMeasObj.leftInch isEqualToString:@"4/8"]){
                    leadMeasObj.leftInch = @"1/2";
                }
                else if([leadMeasObj.leftInch isEqualToString:@"6/8"]){
                    leadMeasObj.leftInch = @"3/4";
                }
                
                
                leadMeasObj.rightFt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 21)];
                if ([leadMeasObj.rightFt isEqualToString:@"(null)"]) {
                    leadMeasObj.rightFt = @"";
                }
                
                leadMeasObj.rightInch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 22)];
                if([leadMeasObj.rightInch isEqualToString:@"2/8"]){
                    leadMeasObj.rightInch = @"1/4";
                }
                else if([leadMeasObj.rightInch isEqualToString:@"4/8"]){
                    leadMeasObj.rightInch = @"1/2";
                }
                else if([leadMeasObj.rightInch isEqualToString:@"6/8"]){
                    leadMeasObj.rightInch = @"3/4";
                }
                
                leadMeasObj.bracketFt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 23)];
                if ([leadMeasObj.bracketFt isEqualToString:@"(null)"]) {
                    leadMeasObj.bracketFt = @"";
                }
                
                leadMeasObj.bracketInch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 24)];
                if([leadMeasObj.bracketInch isEqualToString:@"2/8"]){
                    leadMeasObj.bracketInch = @"1/4";
                }
                else if([leadMeasObj.bracketInch isEqualToString:@"4/8"]){
                    leadMeasObj.bracketInch = @"1/2";
                }
                else if([leadMeasObj.bracketInch isEqualToString:@"6/8"]){
                    leadMeasObj.bracketInch = @"3/4";
                }
                
                
                //leadMeasObj.totalWidth =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 32)];
                
                leadMeasObj.topFt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 25)];
                if ([leadMeasObj.topFt isEqualToString:@"(null)"])
                {
                    
                    leadMeasObj.topFt = @"";
                    
                }
                
                
                leadMeasObj.topInch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 26)];
                if([leadMeasObj.topInch isEqualToString:@"2/8"]){
                    leadMeasObj.topInch = @"1/4";
                }
                else if([leadMeasObj.topInch isEqualToString:@"4/8"]){
                    leadMeasObj.topInch = @"1/2";
                }
                else if([leadMeasObj.topInch isEqualToString:@"6/8"]){
                    leadMeasObj.topInch = @"3/4";
                }
                
                leadMeasObj.bottomFt =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 27)];
                if ([leadMeasObj.bottomFt isEqualToString:@"(null)"]) {
                    leadMeasObj.bottomFt = @"";
                }
                
                leadMeasObj.bottomInch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 28)];
                if([leadMeasObj.bottomInch isEqualToString:@"2/8"])
                {
                    leadMeasObj.bottomInch = @"1/4";
                }
                else if([leadMeasObj.bottomInch isEqualToString:@"4/8"])
                {
                    leadMeasObj.bottomInch = @"1/2";
                }
                else if([leadMeasObj.bottomInch isEqualToString:@"6/8"])
                {
                    leadMeasObj.bottomInch = @"3/4";
                }
                
                //leadMeasObj.totalHeight =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 35)];
                
                leadMeasObj.oldTreatment =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 40)];
                
                
                if ([leadMeasObj.oldTreatment isEqualToString:@"(null)"]) {
                    leadMeasObj.oldTreatment = @"";
                }
                leadMeasObj.headrailSize =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 41)];
                if ([leadMeasObj.headrailSize isEqualToString:@"(null)"]) {
                    leadMeasObj.headrailSize = @"";
                }
                leadMeasObj.cordType =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 42)];
                if ([leadMeasObj.cordType isEqualToString:@"(null)"]) {
                    leadMeasObj.cordType = @"";
                }
                leadMeasObj.tdbu =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 43)];
                if ([leadMeasObj.tdbu isEqualToString:@"(null)"]) {
                    leadMeasObj.tdbu = @"";
                }
                leadMeasObj.roomLabel =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 44)];
                if ([leadMeasObj.roomLabel isEqualToString:@"(null)"]) {
                    leadMeasObj.roomLabel = @"";
                }
                leadMeasObj.pairorSingle =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 45)];
                if ([leadMeasObj.pairorSingle isEqualToString:@"(null)"]) {
                    leadMeasObj.pairorSingle = @"";
                }
                // leadMeasObj.totalwidthCoverage =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 42)];
                if ([leadMeasObj.totalwidthCoverage isEqualToString:@"(null)"]) {
                    leadMeasObj.totalwidthCoverage = @"";
                }
                
                
                leadMeasObj.hardwareWidth =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 29)];
                // leadMeasObj.windowwallHeight =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 44)];
                // leadMeasObj.topofPole =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 45)];
                leadMeasObj.ceilingtofloor =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 46)];
                leadMeasObj.ctof_left_ft =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 48)];
                leadMeasObj.ctof_left_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 49)];
                leadMeasObj.ctof_center_ft =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 50)];
                leadMeasObj.ctof_center_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 51)];
                leadMeasObj.ctof_right_ft =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 52)];
                leadMeasObj.ctof_right_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 53)];
                leadMeasObj.str_hard_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 30)];
                
                leadMeasObj.str_bottum_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 28)];
                leadMeasObj.str_puddle_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 59)];
                leadMeasObj.str_return_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 57)];
                leadMeasObj.str_offthefloor_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 61)];
                leadMeasObj.str_finished_inch =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 18)];
                if ([leadMeasObj.str_hard_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_hard_inch = @"";
                }
                if ([leadMeasObj.str_bottum_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_bottum_inch = @"";
                }
                if ([leadMeasObj.str_puddle_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_puddle_inch = @"";
                }
                if ([leadMeasObj.str_return_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_return_inch = @"";
                }
                if ([leadMeasObj.str_offthefloor_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_offthefloor_inch = @"";
                }
                if ([leadMeasObj.str_finished_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_finished_inch = @"";
                }
                if ([leadMeasObj.ctof_left_ft isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_left_ft = @"";
                }
                if ([leadMeasObj.ctof_left_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_left_inch = @"";
                }
                if ([leadMeasObj.ctof_center_ft isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_center_ft = @"";
                }
                if ([leadMeasObj.ctof_center_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_center_inch = @"";
                }
                if ([leadMeasObj.ctof_right_ft isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_right_ft = @"";
                }
                if ([leadMeasObj.ctof_right_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.ctof_right_inch = @"";
                }
                if ([leadMeasObj.ceilingtofloor isEqualToString:@"(null)"]) {
                    leadMeasObj.ceilingtofloor = @"";
                }
                leadMeasObj.cordSide =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 54)];
                if ([leadMeasObj.cordSide isEqualToString:@"(null)"]) {
                    leadMeasObj.cordSide = @"";
                }
                leadMeasObj.functionality =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 55)];
                if ([leadMeasObj.functionality isEqualToString:@"(null)"]) {
                    leadMeasObj.functionality = @"";
                }
                leadMeasObj.returnn =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 56)];
                if ([leadMeasObj.returnn isEqualToString:@"(null)"]) {
                    leadMeasObj.returnn = @"";
                }
                if(leadMeasObj.returnn.length>0){
                    leadMeasObj.returnStatus = @"1";
                }
                else{
                    leadMeasObj.returnStatus = @"0";
                }
                leadMeasObj.puddle =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 58)];
                if ([leadMeasObj.puddle isEqualToString:@"(null)"]) {
                    leadMeasObj.puddle = @"";
                }
                if(leadMeasObj.puddle.length>0){
                    leadMeasObj.puddleoffStatus = @"1";
                }
                
                
                leadMeasObj.oftheFloor =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 60)];
                
                
                if ([leadMeasObj.oftheFloor isEqualToString:@"(null)"]) {
                    leadMeasObj.oftheFloor = @"";
                }
                if(leadMeasObj.oftheFloor.length>0){
                    leadMeasObj.puddleoffStatus = @"2";
                }
                
                leadMeasObj.tiltType =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 62)];
                if ([leadMeasObj.tiltType isEqualToString:@"(null)"]) {
                    leadMeasObj.tiltType = @"";
                }
                leadMeasObj.spacerNeeded = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 63)];
                if ([leadMeasObj.spacerNeeded isEqualToString:@"(null)"]) {
                    leadMeasObj.spacerNeeded = @"";
                }
                leadMeasObj.systemm = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 64)];
                if ([leadMeasObj.systemm isEqualToString:@"(null)"]) {
                    leadMeasObj.systemm = @"";
                }
                leadMeasObj.installationNote = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 32)];
                if ([leadMeasObj.installationNote isEqualToString:@"(null)"]) {
                    leadMeasObj.installationNote = @"";
                }
                leadMeasObj.notes = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 33)];
                if ([leadMeasObj.notes isEqualToString:@"(null)"]) {
                    leadMeasObj.notes = @"";
                }
                leadMeasObj.finishedLength = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 17)];
                if ([leadMeasObj.finishedLength isEqualToString:@"(null)"]) {
                    leadMeasObj.finishedLength = @"";
                }
                
                leadMeasObj.controlType = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 66)];
                if ([leadMeasObj.controlType isEqualToString:@"(null)"]) {
                    leadMeasObj.controlType = @"";
                }
                
                leadMeasObj.poleTopFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 67)];
                if (leadMeasObj.poleTopFt.length ==0) {
                    leadMeasObj.poleTopFt = @"0";
                }
                leadMeasObj.poleTopInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 68)];
                if (leadMeasObj.poleTopInch.length ==0) {
                    leadMeasObj.poleTopInch = @"0";
                }
                leadMeasObj.poleHeightFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 69)];
                if (leadMeasObj.poleHeightFt.length ==0) {
                    leadMeasObj.poleHeightFt = @"0";
                }
                leadMeasObj.poleHeightInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 70)];
                if (leadMeasObj.poleHeightInch.length ==0) {
                    leadMeasObj.poleHeightInch = @"0";
                }
                
                leadMeasObj.str_bottum_inch= [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 72)];
                if (leadMeasObj.str_bottum_inch.length ==0) {
                    leadMeasObj.str_bottum_inch = @"0";
                }
                if ([leadMeasObj.str_bottum_inch isEqualToString:@"(null)"]) {
                    leadMeasObj.str_bottum_inch = @"";
                }
                
                leadMeasObj.lining = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 74)];
                if (leadMeasObj.lining.length ==0)
                {
                    leadMeasObj.lining = @"";
                }
                
                leadMeasObj.poleTopFt = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 67)];
                
                leadMeasObj.poleTopInch = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 68)];
                leadMeasObj.bootomOfCrownFloor = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 71)];
                
                [off_total_measurment addObject:leadMeasObj];
                
                
            }
            
        }
        else
        {
            ////////////////NSLog(@"problem in query statement");
        }
        sqlite3_finalize(compiledStatement);
    }
    
    sqlite3_close(database);
    
  [self updateOfflineMeasurment];
    
    
}

-(void)updateOfflineMeasurment
{
    if(off_total_measurment.count>measurment_current_index)
    {
        
        
        current_leasd_meas=[off_total_measurment objectAtIndex:measurment_current_index];
        
        if([leadMeasObj.webMeasurementID isEqualToString:@"0"])
        {
          
            
            [self sendingUpdatedMeasurementDeatilToWeb:current_leasd_meas andMode:@"new"];
            
            
        }
        else
        {
            
            
            [self sendingUpdatedMeasurementDeatilToWeb:current_leasd_meas andMode:@"edit"];
            
            
        }
        
        
    }
    else
    {
        [self getTotalOffCheckListId];
       
        
    }

}
-(void)getTotalOffCheckListId
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"select localleadID from rst_checklist where offlineFlag=%i ;",1];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                
                NSString *lid = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                [total_local_lead_check addObject:lid];
                
                
            }
            
        }
        else
        {
            NSLog(@"problem in rst_measurement_image statement");
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    [self updateOfflineCheck];
    
}
-(void)updateOfflineCheck
{
    
    NSMutableArray *InstArr=[[NSMutableArray alloc]init];
    NSMutableArray *timezoneArr=[[NSMutableArray alloc]init];
    NSMutableArray *checkListArr=[[NSMutableArray alloc]init];
    if(total_local_lead_check.count>check_current_index)
    {
        
        if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
        {
            
            NSString * insertSQL = [NSString stringWithFormat:@"select insuranceNeeded,concrete,metal,wood,floorUnlevel,noDoorMan,ladder,littleGiant,tdOldBlinds,cUnlevel,wFrameUnlevel,highWire from rst_specialinstruction where localleadID =%@",[total_local_lead_check objectAtIndex:check_current_index]];
            const char *sqlStatement = [insertSQL UTF8String];
            sqlite3_stmt * compiledStatement;
            
            if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
                while (sqlite3_step(compiledStatement)==SQLITE_ROW)
                {
                    
                    NSString *spec_instr1 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                    NSString *spec_instr2 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 1)];
                    NSString *spec_instr3 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 2)];
                    NSString *spec_instr4 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 3)];
                    NSString *spec_instr5 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 4)];
                    NSString *spec_instr6 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 5)];
                    NSString *spec_instr7 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 6)];
                    NSString *spec_instr8 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 7)];
                    NSString *spec_instr9 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 8)];
                    NSString *spec_instr10 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 9)];
                    NSString *spec_instr11 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 10)];
                    NSString *spec_instr12 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 11)];
                    if([spec_instr1 intValue]==1)
                    {
                        spec_instr1=@"1";
                    }
                    if([spec_instr2 intValue]==1)
                    {
                        spec_instr2=@"2";
                    }
                    if([spec_instr3 intValue]==1)
                    {
                        spec_instr3=@"3";
                    }
                    if([spec_instr4 intValue]==1)
                    {
                        spec_instr4=@"4";
                    }
                    if([spec_instr5 intValue]==1)
                    {
                        spec_instr5=@"5";
                    }
                    if([spec_instr6 intValue]==1)
                    {
                        spec_instr6=@"6";
                    }
                    if([spec_instr7 intValue]==1)
                    {
                        spec_instr7=@"7";
                    }
                    if([spec_instr8 intValue]==1)
                    {
                        spec_instr8=@"8";
                    }
                    if([spec_instr9 intValue]==1)
                    {
                        spec_instr9=@"9";
                    }
                    if([spec_instr10 intValue]==1)
                    {
                        spec_instr10=@"10";
                    }
                    if([spec_instr11 intValue]==1)
                    {
                        spec_instr11=@"11";
                    }
                    if([spec_instr12 intValue]==1)
                    {
                        spec_instr12=@"12";
                    }
                    
                    
                    [InstArr addObject:spec_instr1];
                    [InstArr addObject:spec_instr2];
                    [InstArr addObject:spec_instr3];
                    [InstArr addObject:spec_instr4];
                    [InstArr addObject:spec_instr5];
                    [InstArr addObject:spec_instr6];
                    [InstArr addObject:spec_instr7];
                    [InstArr addObject:spec_instr8];
                    [InstArr addObject:spec_instr9];
                    [InstArr addObject:spec_instr10];
                    [InstArr addObject:spec_instr11];
                    [InstArr addObject:spec_instr12];
                    
                    
                    
                }
            }
            else
            {
                
                ////////NSLog(@"problem in query statement");
                
            }
            sqlite3_finalize(compiledStatement);
        }sqlite3_close(database);
        
        
        
        if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
            NSString * insertSQL = [NSString stringWithFormat:@"select estimatedTime_1,estimatedTime_1_2,estimatedTime_2_3,estimatedTime_3_4,estimatedTime_4_5 from rst_estimatedTime where localleadID =%@",[total_local_lead_check objectAtIndex:check_current_index]];
            const char *sqlStatement = [insertSQL UTF8String];
            sqlite3_stmt * compiledStatement;
            if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
                while (sqlite3_step(compiledStatement)==SQLITE_ROW) {
                    NSString *spec_instr1 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                    NSString *spec_instr2 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 1)];
                    NSString *spec_instr3 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 2)];
                    NSString *spec_instr4 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 3)];
                    NSString *spec_instr5 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 4)];
                    
                    if([spec_instr1 intValue]==1)
                    {
                        spec_instr1=@"1";
                    }
                    if([spec_instr2 intValue]==1)
                    {
                        spec_instr2=@"2";
                    }
                    if([spec_instr3 intValue]==1)
                    {
                        spec_instr3=@"3";
                    }
                    if([spec_instr4 intValue]==1)
                    {
                        spec_instr4=@"4";
                    }
                    if([spec_instr5 intValue]==1)
                    {
                        spec_instr5=@"5";
                    }
                    
                    [timezoneArr addObject:spec_instr1];
                    [timezoneArr addObject:spec_instr2];
                    [timezoneArr addObject:spec_instr3];
                    [timezoneArr addObject:spec_instr4];
                    [timezoneArr addObject:spec_instr5];
                    
                }
            }
            else{
            }
            sqlite3_finalize(compiledStatement);
        }sqlite3_close(database);
        
        
        
        
        
        if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
            NSString * insertSQL = [NSString stringWithFormat:@"select checkedDraperyStackback,clearBaseboards,romanSahadeClearWindows,cornerWindow,clearTheHandle,blackoutGaps,clearTheCasing from rst_checklist where localleadID =%@",[total_local_lead_check objectAtIndex:check_current_index]];
            
            const char *sqlStatement = [insertSQL UTF8String];
            sqlite3_stmt * compiledStatement;
            
            if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
                ////////NSLog(@"in database");
                while (sqlite3_step(compiledStatement)==SQLITE_ROW) {
                    NSString *spec_instr1 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                    NSString *spec_instr2 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 1)];
                    NSString *spec_instr3 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 2)];
                    NSString *spec_instr4 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 3)];
                    NSString *spec_instr5 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 4)];
                    NSString *spec_instr6 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 5)];
                    NSString *spec_instr7 = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 6)];
                    
                    
                    if([spec_instr1 intValue]==1)
                    {
                        spec_instr1=@"1";
                    }
                    if([spec_instr2 intValue]==1)
                    {
                        spec_instr2=@"2";
                    }
                    if([spec_instr3 intValue]==1)
                    {
                        spec_instr3=@"3";
                    }
                    if([spec_instr4 intValue]==1)
                    {
                        spec_instr4=@"4";
                    }
                    if([spec_instr5 intValue]==1)
                    {
                        spec_instr5=@"5";
                    }
                    if([spec_instr6 intValue]==1)
                    {
                        spec_instr6=@"6";
                    }
                    if([spec_instr7 intValue]==1)
                    {
                        spec_instr7=@"7";
                    }
                    
                    
                    [checkListArr addObject:spec_instr1];
                    [checkListArr addObject:spec_instr2];
                    [checkListArr addObject:spec_instr3];
                    [checkListArr addObject:spec_instr4];
                    [checkListArr addObject:spec_instr5];
                    [checkListArr addObject:spec_instr6];
                    [checkListArr addObject:spec_instr7];
                    
                    
                }
            }
            else
            {
                //////NSLog(@"problem in query statement");
            }
            sqlite3_finalize(compiledStatement);
        }sqlite3_close(database);

        
        
        
         [InstArr removeObject:@"0"];
         [timezoneArr removeObject:@"0"];
         [checkListArr removeObject:@"0"];
        
        NSArray  *arr_sp = [[NSSet setWithArray:InstArr] allObjects];
        NSArray  *arr_est = [[NSSet setWithArray:timezoneArr] allObjects];
        NSArray  *arr_check = [[NSSet setWithArray:checkListArr] allObjects];
        
        total_off_check_list=[NSMutableArray arrayWithArray:arr_check];
        total_off_esttime_list=[NSMutableArray arrayWithArray:arr_est];
        total_off_speacins_list=[NSMutableArray arrayWithArray:arr_sp];
        
      

      
        
        off_str_check_list = [total_off_check_list componentsJoinedByString:@","];
        off_str_esttime_list = [total_off_esttime_list componentsJoinedByString:@","];
        off_str_speacins_list = [total_off_speacins_list componentsJoinedByString:@","];
        
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        NSString *leadID=[dbSingleton() get_webleadid_of_localleadid:[total_local_lead_check objectAtIndex:check_current_index]];
        
        NSString *strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addMeasurementCheckList&leadID=%@&measurementID=0",leadID];
     
       
        
        request_check_list = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
        request_check_list.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"checklist",@"request",nil];
        [request_check_list setDelegate:self];
        [request_check_list setPostValue:off_str_speacins_list forKey:@"specialInstruction"];
        [request_check_list setPostValue:off_str_esttime_list forKey:@"estimatedTime"];
        [request_check_list setPostValue:off_str_check_list forKey:@"checklist"];
        [request_check_list startAsynchronous];
        

        
    }
    else
    {
        
        //[delegate OffsyncFinished];
        [self getTotal_offIssue];
        
    }
    
}

-(void)getTotal_offIssue
{
    
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        
        sqlite3_stmt * compiledStatement;
        
        
        NSString *insertSQL = [NSString stringWithFormat:@"select webmeasurementID,issueNote from rst_images where issueID=0 AND imageType=4;"];
        const char *sqlStatement = [insertSQL UTF8String];
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                
                NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
                NSString *webmes_id = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 0)];
                NSString *issue_note = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 1)];
                [dic setObject:webmes_id forKey:@"webmes_id"];
                [dic setObject:issue_note forKey:@"issue_note"];
                [off_issue_arr addObject:dic];
                
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        sqlStatement=nil;
    }
    else
    {
        sqlite3_close(database);
    }
    [self updateOfflineIssue];
    
}
     
-(void)updateOfflineIssue
{
    
 
    if(off_issue_arr.count>current_issue_index)
    {
        
        NSString *meas_id=[[off_issue_arr objectAtIndex:current_issue_index] objectForKey:@"webmes_id"];
        NSString *issue_note=[[off_issue_arr objectAtIndex:current_issue_index] objectForKey:@"issue_note"];
        NSString *lead_id=[dbSingleton() get_webleadid_of_webmeasurementid:[meas_id intValue]];
        request_issue_list=nil;
        NSString * strURL;
        strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addwindowissue&leadID=%@&measurementID=%@&issueContent=%@",lead_id,meas_id,issue_note];
        strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        request_issue_list = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
        request_issue_list.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"addIssue",@"request", nil];
        [request_issue_list setDelegate:self];
        [request_issue_list startAsynchronous];
        
    }
    else
    {
        [self getTotal_offPayment];
        //[delegate OffsyncFinished];
    }
    
}


-(void)getTotal_offPayment
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        
        sqlite3_stmt * compiledStatement;
        
        
        NSString *insertSQL = [NSString stringWithFormat:@"select * from rst_Payments where webPaymentID= '0'"];
        
        const char *sqlStatement = [insertSQL UTF8String];
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                
                pay_info = [[paymentInfo alloc]init];
                pay_info.ID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 0)];
                
                pay_info.leadID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 1)];
                pay_info.amount = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 3)];
                pay_info.paymentMode = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 4)];
                pay_info.chequeNumber = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 5)];
                pay_info.bankName = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 6)];
                
                pay_info.cardType =  [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 7)];
                pay_info.cardNumber =  [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 8)];
                pay_info.expMonth =  [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 9)];
                
                pay_info.expYear =  [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 10)];
                pay_info.veriNumber =  [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 11)];
                pay_info.invoiceID = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 13)];
                pay_info.receiptID =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 14)];
                pay_info.checkName =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 16)];
                pay_info.signName =[NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 17)];
                [total_off_payment addObject:pay_info];
                
                
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        sqlStatement=nil;
    }
    else
    {
        sqlite3_close(database);
    }
    
    [self updateOfflinePayment];
    
}

-(void)updateOfflinePayment
{
    
    if(total_off_payment.count>current_payment_index)
    {
        [self sendingPaymentDetailToWeb:[total_off_payment objectAtIndex:current_payment_index]];
    }
    else
    {
       // [delegate OffsyncFinished];
        [self getOfflineDeleted];
    }
    
}

-(void)getOfflineDeleted
{
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"select webleadID,webMesurementID from rst_lead_measurement_info where offlineDeletionFlag ='1';"];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
                NSString *leadid = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 0)];
                NSString *measurementid = [NSString stringWithFormat:@"%s",(char * )sqlite3_column_text(compiledStatement, 1)];
                [dic setObject:leadid forKey:@"leadid"];
                [dic setObject:measurementid forKey:@"measurementid"];
                [total_off_deleted addObject:dic];
                
            }
            
        }
        else
        {
        }
        sqlite3_finalize(compiledStatement);
        sqlite3_close(database);
        
    }
    
    sqlite3_close(database);
    
   
       
    [self sending_deleted_Measurement_Deatil_ToWeb];
        
    
    
}
-(void)sending_deleted_Measurement_Deatil_ToWeb
{
    
    if(total_off_deleted.count>current_deleted_index)
    {
    NSString *leadid=[[total_off_deleted objectAtIndex:current_deleted_index] objectForKey:@"leadid"];
    NSString *mesid=[[total_off_deleted objectAtIndex:current_deleted_index] objectForKey:@"measurementid"];
    NSString *strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=deletemeasurement&leadID=%@&measurementID=%@",leadid,mesid];
    request_delete = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    request_delete.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"deletemeasurement",@"request",nil];
    [request_delete setDelegate:self];
    [request_delete addRequestHeader:@"Content-Type" value:@"application/json"];
    [request_delete startSynchronous];
    }
    else
    {
        [delegate OffsyncFinished];
    }
    
    
}

-(void)sendingPaymentDetailToWeb:(paymentInfo *)pay
{
    
    
    
    NSString *strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addMeasurementPayment&measurementID=0&leadID=%@",pay.leadID];
    request_payment = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    [request_payment setDelegate:self];
    request_payment.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"addpayment",@"request", nil];
    [request_payment setPostValue:pay.amount forKey:@"amount"];
    
    [request_payment setPostValue:@"" forKey:@"comment"];
    
    [request_payment setPostValue:pay.paymentMode forKey:@"modeOfPayment"];
    
    [request_payment setPostValue:pay.chequeNumber forKey:@"chequeNumber"];
    
    [request_payment setPostValue:pay.bankName forKey:@"bankName"];
    
    [request_payment setPostValue:@"1" forKey:@"paymentStatus"];
    
    [request_payment setPostValue:pay.cardType forKey:@"creditCardType"];
    
    [request_payment setPostValue:pay.cardNumber forKey:@"creditCardNumber"];
    
    [request_payment setPostValue:pay.expMonth forKey:@"expDateMonth"];
    
    [request_payment setPostValue:pay.veriNumber forKey:@"cvv2Number"];
    
    [request_payment setPostValue:pay_info.expYear forKey:@"expDateYear"];
    
    [request_payment setPostValue:pay.invoiceID forKey:@"invoiceID"];
    [request_payment setPostValue:@"1" forKey:@"checkPaymentStatus"];
    
    
    [request_payment startAsynchronous];
    
    
    
    
    
}


-(void)sendingUpdatedMeasurementDeatilToWeb:(leadMeasurementInfotab2*)leadMeaInfo andMode:(NSString *)mode
{
    
    
    NSString * strURL;
    if ([mode isEqualToString:@"new"])
    {
        
        
        strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addmeasurement&leadID=%@&measurementID=&mode=add",leadMeaInfo.leadID];
        
    }
    else if ([mode isEqualToString:@"edit"])
    {
        
        
        strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addmeasurement&leadID=%@&measurementID=%@&mode=edit",leadMeaInfo.leadID,leadMeaInfo.webMeasurementID];
        
    }
    
    
    
    request_measurment = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    request_measurment.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"addmeasurement",@"request",nil];
    [request_measurment setDelegate:self];
    [request_measurment addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *dic =[self createDictofarray:leadMeaInfo];
    NSString *jsonData = [dic JSONString];
    [request_measurment setPostValue:jsonData forKey:@"formdata"];
    [request_measurment setShouldAttemptPersistentConnection:NO];
    [request_measurment startSynchronous];
    
    
    
    
}



-(NSMutableDictionary *)createDictofarray:(leadMeasurementInfotab2*)leadMeaInfo
{
    
    
    
    leadMeasObj2 = leadMeaInfo;
    formoneDict = [[NSMutableDictionary alloc] init];
    [formoneDict setValue:leadMeasObj2.formType forKey:@"formType"];
    [formoneDict setValue:leadMeasObj2.webMeasurementID forKey:@"measurementID"];
    [formoneDict setValue:leadMeasObj2.mID forKey:@"mID"];
    [formoneDict setValue:leadMeasObj2.leadID forKey:@"leadID"];
    [formoneDict setValue:leadMeasObj2.productID forKey:@"productID"];
    [formoneDict setValue:leadMeasObj2.widthFt forKey:@"widthFt"];
    [formoneDict setValue:leadMeasObj2.widthInch forKey:@"widthInch"];
    [formoneDict setValue:leadMeasObj2.heightFt forKey:@"heightFt"];
    [formoneDict setValue:leadMeasObj2.heightInch forKey:@"heightInch"];
    [formoneDict setValue:leadMeasObj2.depthFt forKey:@"depthFt"];
    [formoneDict setValue:leadMeasObj2.depthInch forKey:@"depthInch"];
    [formoneDict setValue:leadMeasObj2.rollType forKey:@"rollType"];
    [formoneDict setValue:leadMeasObj2.mountType forKey:@"mountType"];
    [formoneDict setValue:leadMeasObj2.controlPosition forKey:@"controlPosition"];
    [formoneDict setValue:leadMeasObj2.totalHardwareWidth forKey:@"totalHardwareWidth"];
    [formoneDict setValue:leadMeasObj2.product forKey:@"product"];
    [formoneDict setValue:leadMeasObj2.material forKey:@"material"];
    [formoneDict setValue:leadMeasObj2.creationDate forKey:@"creationDate"];
    [formoneDict setValue:leadMeasObj2.updationDate forKey:@"updationDate"];
    [formoneDict setValue:leadMeasObj2.windowSidemark forKey:@"windowSidemark"];
    [formoneDict setValue:leadMeasObj2.laye forKey:@"layer"];
    [formoneDict setValue:leadMeasObj2.type forKey:@"type"];
    [formoneDict setValue:leadMeasObj2.optionalFeatures forKey:@"optionalFeatures"];
    [formoneDict setValue:leadMeasObj2.extentionBracket forKey:@"extensionBracket"];
    [formoneDict setValue:leadMeasObj2.mountType2 forKey:@"mountTypeW"];
    [formoneDict setValue:leadMeasObj2.leftFt forKey:@"leftFt"];
    [formoneDict setValue:leadMeasObj2.leftInch forKey:@"leftInch"];
    [formoneDict setValue:leadMeasObj2.rightFt forKey:@"rightFt"];
    [formoneDict setValue:leadMeasObj2.rightInch forKey:@"rightInch"];
    [formoneDict setValue:leadMeasObj2.bracketFt forKey:@"bracketFt"];
    [formoneDict setValue:leadMeasObj2.bracketInch forKey:@"bracketInch"];
    [formoneDict setValue:leadMeasObj2.totalWidth forKey:@"totalWidth"];
    [formoneDict setValue:leadMeasObj2.topFt forKey:@"topFt"];
    [formoneDict setValue:leadMeasObj2.topInch forKey:@"topInch"];
    [formoneDict setValue:leadMeasObj2.bottomFt forKey:@"bottomFt"];
    [formoneDict setValue:leadMeasObj2.bottomInch forKey:@"bottomInch"];
    [formoneDict setValue:leadMeasObj2.totalHeight forKey:@"totalHeight"];
    [formoneDict setValue:leadMeasObj2.oldTreatment forKey:@"oldTreatment"];
    [formoneDict setValue:leadMeasObj2.headrailSize forKey:@"headrailSize"];
    [formoneDict setValue:leadMeasObj2.cordType forKey:@"cordType"];
    [formoneDict setValue:leadMeasObj2.tdbu forKey:@"tdbu"];
    if ([leadMeasObj2.roomLabel isEqualToString:@"MBR"]||[leadMeasObj2.roomLabel isEqualToString:@"LR"]||[leadMeasObj2.roomLabel isEqualToString:@"DR"]) {
        
    }
    else{
        leadMeasObj2.winTitle = leadMeasObj2.roomLabel;
        leadMeasObj2.roomLabel = @"OTHER";
        
    }
    [formoneDict setValue:leadMeasObj2.quantity forKey:@"quantity"];
    [formoneDict setValue:leadMeasObj2.lining forKey:@"linening"];
    
    [formoneDict setValue:leadMeasObj2.roomLabel forKey:@"roomLabel"];
    [formoneDict setValue:leadMeasObj2.winTitle forKey:@"winTitle"];
    [formoneDict setValue:leadMeasObj2.pairorSingle forKey:@"pairSingle"];
    [formoneDict setValue:leadMeasObj2.hardwareWidth forKey:@"hardwareWidth"];
    [formoneDict setValue:leadMeasObj2.str_hard_inch forKey:@"hardwareWidth2"];
    [formoneDict setValue:leadMeasObj2.windowwallHeight forKey:@"windowwallHeight"];
    [formoneDict setValue:leadMeasObj2.topofPole forKey:@"topofPole"];
    [formoneDict setValue:leadMeasObj2.ceilingtofloor forKey:@"ceilingtofloor"];
    [formoneDict setValue:leadMeasObj2.cordSide forKey:@"cordSide"];
    [formoneDict setValue:leadMeasObj2.functionality forKey:@"functionality"];
    [formoneDict setValue:leadMeasObj2.returnn forKey:@"returnVal"];
    [formoneDict setValue:leadMeasObj2.str_return_inch forKey:@"returnVal2"];
    [formoneDict setValue:leadMeasObj2.puddle forKey:@"puddle"];
    if (leadMeasObj2.returnn.length>0) {
        [formoneDict setValue:@"1" forKey:@"returnType"];
    }
    else{
        [formoneDict setValue:@"0" forKey:@"returnType"];
    }
    
    
    
    if (leadMeasObj2.puddle.length>0)
    {
        
        [formoneDict setValue:leadMeasObj2.puddle forKey:@"puddle"];
        [formoneDict setValue:leadMeasObj2.str_puddle_inch forKey:@"puddle2"];
        [formoneDict setValue:@"1" forKey:@"poType"];
    }
    else if(leadMeasObj2.oftheFloor.length>0)
    {
        [formoneDict setValue:leadMeasObj2.oftheFloor forKey:@"puddle"];
        [formoneDict setValue:leadMeasObj2.str_offthefloor_inch forKey:@"puddle2"];
        [formoneDict setValue:@"2" forKey:@"poType"];
    }
    
    [formoneDict setValue:leadMeasObj2.oftheFloor forKey:@"offTheFloor"];
    [formoneDict setValue:leadMeasObj2.tiltType forKey:@"tiltType"];
    [formoneDict setValue:leadMeasObj2.spacerNeeded forKey:@"spacerNeeded"];
    [formoneDict setValue:leadMeasObj2.systemm forKey:@"system"];
    [formoneDict setValue:leadMeasObj2.notes forKey:@"specialNotes"];
    [formoneDict setValue:leadMeasObj2.installationNote forKey:@"installerInstruction"];
    [formoneDict setValue:leadMeasObj2.ctofValue forKey:@"ceilingToFloorValue"];
    //Usman
    [formoneDict setValue:leadMeasObj2.ctof_left_ft forKey:@"cfleftFt"];
    [formoneDict setValue:leadMeasObj2.ctof_left_inch forKey:@"cfleftInch"];
    [formoneDict setValue:leadMeasObj2.ctof_center_ft forKey:@"cfcenterFt"];
    [formoneDict setValue:leadMeasObj2.ctof_center_inch forKey:@"cfcenterInch"];
    [formoneDict setValue:leadMeasObj2.ctof_right_ft forKey:@"cfrightFt"];
    [formoneDict setValue:leadMeasObj2.ctof_right_inch forKey:@"cfrightInch"];
    //
    [formoneDict setValue:leadMeasObj2.finishedLength forKey:@"finishedLength"];
    [formoneDict setValue:leadMeasObj2.str_finished_inch forKey:@"finishedLength2"];
    [formoneDict setValue:leadMeasObj2.poleTopFt forKey:@"poleTopFt"];
    [formoneDict setValue:leadMeasObj2.poleTopInch forKey:@"poleTopInch"];
    [formoneDict setValue:leadMeasObj2.poleHeightFt forKey:@"poleHeightFt"];
    [formoneDict setValue:leadMeasObj2.poleHeightInch forKey:@"poleHeightInch"];
    [formoneDict setValue:leadMeasObj2.bootomOfCrownFloor forKey:@"bootomOfCrownFloor"];
    [formoneDict setValue:leadMeasObj2.str_bottum_inch forKey:@"bootomOfCrownFloor2"];
    [formoneDict setValue:leadMeasObj2.controlType forKey:@"controlType"];
    
    value33++;
    
    [formoneDict setValue:[NSString stringWithFormat:@"%i",value33] forKey:@"requestFlag"];
    NSMutableArray *onearr = [[NSMutableArray alloc]init];
    [onearr insertObject:formoneDict atIndex:0];
    NSMutableDictionary *allValueDict = [[NSMutableDictionary alloc]init];
    if ([leadMeasObj2.formType isEqualToString:@"1"])
    {
        
        [allValueDict setObject:formoneDict forKey:@"formone"];
        
    }
    else
    {
        
        [allValueDict setObject:formoneDict forKey:@"formtwo"];
        
    }
    return allValueDict;
    
    
    
    
}



-(void)send_request_for_customer_to_web:(customerDetails *)cus_info
{
    
   
    request_lead=nil;
    NSString * strURL;
    strURL = [NSString stringWithFormat:@"http://www.rstbuilders.com/crm/rstbuilderapi.php?action=addcustomer"];
    request_lead = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    request_lead.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"addcustomer",@"request", nil];
    [request_lead setDelegate:self];
    [request_lead setPostValue:cus_info.lead_hash forKey:@"mLeadID"];
    
    
    NSString *value;
    
    if ([cus_info.manufac_name isEqualToString:@"TSS"])
    {
        value = @"1";
    }
    else if ([cus_info.manufac_name isEqualToString:@"R&B"])
    {
        value = @"2";
    }
    else
    {
        value = @"3";
    }
    
    
    [request_lead setPostValue:cus_info.localLeadID forKey:@"iPadLeadID"];
    
    [request_lead setPostValue:value forKey:@"manufactureID"];
    
    [request_lead setPostValue:cus_info.nameStr forKey:@"firstName"];
    
    [request_lead setPostValue:cus_info.lastName forKey:@"lastName"];
    
    [request_lead setPostValue:cus_info.addressStr forKey:@"address"];
    
    [request_lead setPostValue:cus_info.phoneStr forKey:@"contactNumber[1]"];
    [request_lead setPostValue:cus_info.phoneStr1 forKey:@"contactNumber[2]"];
    [request_lead setPostValue:cus_info.office_phoneStr forKey:@"contactNumber[3]"];
    [request_lead setPostValue:cus_info.emailStr forKey:@"emailID"];
    
    [request_lead setPostValue:cus_info.total_window_door forKey:@"noOfWindows"];
    
    [request_lead setPostValue:cus_info.widow_treatment_type forKey:@"treatmentTypeTitle"];
    
    [request_lead setPostValue:cus_info.manuf_comnt forKey:@"manufacturerComment"];
    
    [request_lead setPostValue:cus_info.salesRep forKey:@"salesRep"];
    
    [request_lead setPostValue:cus_info.map_id forKey:@"mapID"];
    
    [request_lead setPostValue:cus_info.comnt forKey:@"ourComment"];
    
    [request_lead setPostValue:cus_info.manuf_order_url forKey:@"manufacturerOrderUrl"];
    
    [request_lead setPostValue:@"Measurement" forKey:@"leadType"];
    
    customer_id_for_lead = cus_info.localcust_Id;
    
    [request_lead startAsynchronous];
    
    
}


- (void)requestFinished:(ASIFormDataRequest *)request
{
    
    
	NSString *receivedString = [request responseString];
    NSDictionary *results = [receivedString objectFromJSONString];
    NSString *valueif_userinfo = [request.userInfo valueForKey:@"request"];
    
    if ([valueif_userinfo isEqualToString:@"addcustomer"])
    {
        
        NSArray * arr1 = [results objectForKey:@"customer"];
        NSString *StFlag=[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        if([StFlag isEqualToString:@"false"])
        {
            
        }
        else
        {
            
            
            
            NSArray *arr2 = [results objectForKey:@"lead"];
            NSArray *arr3 = [results objectForKey:@"iPadLeadID"];
            NSString *c_id = [arr2 objectAtIndex:0];
            NSString *local_id = [arr3 objectAtIndex:0];
            [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
            [dbSingleton() setleadid_fornewCustomer:[c_id intValue] andCust_id:0 andlocalCustId:[local_id intValue]];
            [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
            [dbSingleton() setLeadid_for_localLeadid_in_measurementTable:[c_id intValue] andlocalLeadId:[local_id intValue]];
            
            
            
        }
        
        lead_current_index=lead_current_index+1;
        [self updateOfflineLead];
        
    }
    
    else if([valueif_userinfo isEqualToString:@"addmeasurement"])
    {
        
        
        NSArray *webid = [[results valueForKey:@"measurementInfo"]valueForKey:@"measurementID"];
        if (webid.count != 0)
        {
          
            
            NSString *local_meas=current_leasd_meas.localMeasurementID;
            [webMeasureIdArr insertObject:[webid objectAtIndex:0] atIndex:0];
            [self checkAndCreateDatabase];
            [self setwebMeasurementidfornewMeasument:[[webMeasureIdArr objectAtIndex:0] intValue] localMeasuermentid:[local_meas intValue]];
            [self setwebMid_in_measurementTable:[[webMeasureIdArr objectAtIndex:0] intValue] localMeasuermentid:[local_meas intValue]];
            [self checkAndCreateDatabase];
            [self get_measurement_image_data_of_web_mid:[[webMeasureIdArr objectAtIndex:0] intValue]];
            [self get_sketch_image_data_of_web_mid:[[webMeasureIdArr objectAtIndex:0] intValue]];
            [self get_preset_image_data_of_web_mid:[[webMeasureIdArr objectAtIndex:0] intValue]];
            
            
        }
        else
        {
            
           
            
        }
         NSLog(@"after adding....");
         measurment_current_index=measurment_current_index+1;
         [self updateOfflineMeasurment];
        
        
    }
    else if ([valueif_userinfo isEqualToString:@"checklist"])
    {
        
        NSString *str=[results objectForKey:@"leadID"];
        [self update_rst_checklist:str];
        [self update_rst_estimatedTime:str];
        [self update_rst_specialinstruction:str];
        check_current_index=check_current_index+1;
        [self updateOfflineCheck];
        
    }
    else if ([valueif_userinfo isEqualToString:@"addIssue"])
    {
        NSString *str=[[off_issue_arr objectAtIndex:current_issue_index] objectForKey:@"webmes_id"];
        NSArray *arr =[results valueForKey:@"issueID"];
        [self send_issue_image_to_web:[arr objectAtIndex:0] and:str];
        NSString *issue_id=[arr objectAtIndex:0];
        [self updateIssue:issue_id];
        current_issue_index=current_issue_index+1;
        [self updateOfflineIssue];
        
    }
    else if ([valueif_userinfo isEqualToString:@"addpayment"])
    {
        
        
        paymentInfo *Info=[total_off_payment objectAtIndex:current_payment_index];
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        [dbSingleton() set_web_pament_id:[results objectForKey:@"mPayID"] forrecord:Info.ID];
        current_payment_index=current_payment_index+1;
        NSString *str=[results objectForKey:@"mPayID"];
        
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        [self uploadsignatureImage:str LeadId:Info.leadID InvoiceId:Info.invoiceID Name:Info.signName];
        
        if([Info.paymentMode isEqualToString:@"Cheque"])
        {
          [self uploadchequeImage:str LeadId:Info.leadID InvoiceId:Info.invoiceID Name:Info.checkName];
        }
        
        [self updateOfflinePayment];
        
        
    }
    if ([valueif_userinfo isEqualToString:@"deletemeasurement"])
    {
        if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
        {
            
            
            NSString *mesid=[[total_off_deleted objectAtIndex:current_deleted_index] objectForKey:@"measurementid"];
            NSString * insertSQL = [NSString stringWithFormat:@"delete from rst_lead_measurement_info where webMesurementID=%@",mesid ];
            const char *sqlStatement = [insertSQL UTF8String];
            sqlite3_stmt * compiledStatement;
            
            if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
            {
                
                
                while (sqlite3_step(compiledStatement)==SQLITE_ROW)
                {
                    NSLog(@"....deleted......");
                }
                
                
                
            }
            else
            {
                
            }
            
            sqlite3_finalize(compiledStatement);
            
        }sqlite3_close(database);
        current_deleted_index=current_deleted_index+1;
        [self sending_deleted_Measurement_Deatil_ToWeb];
    
    }


}

-(void)uploadchequeImage:(NSString *)web_payid LeadId:(NSString *)leadID InvoiceId:(NSString *)invoiceID Name:(NSString *)imageName
{
   
    NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imageName];
    NSData *imagedata = [NSData dataWithContentsOfFile:path];
    if (imagedata!=nil )
    {
        
        
        
         NSString *string=[NSString stringWithFormat:@"http://www.rstbuilders.com/crm/upload-measurement-images.php?measurementID=%@&leadID=%@&invoiceID=%@&imageCounter=1&uploadType=checkImage&mPayID=%@",@"0",leadID,invoiceID,web_payid];
        
        NSURL *url=[NSURL URLWithString:string];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[NSData dataWithData:imagedata]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString*str22 = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSString * str2=[str22 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        str2=[str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSLog(@"off cheque str2....%@",str2);
        
    }
    
}

-(void)uploadsignatureImage:(NSString *)web_payid LeadId:(NSString *)leadID InvoiceId:(NSString *)invoiceID Name:(NSString *)imageName
{
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imageName];
    NSData *imagedata = [NSData dataWithContentsOfFile:path];
    if (imagedata!=nil )
    {
        
        
        
        NSString *string=[NSString stringWithFormat:@"http://www.rstbuilders.com/crm/upload-measurement-images.php?measurementID=%@&leadID=%@&invoiceID=%@&imageCounter=1&uploadType=signatureImage&mPayID=%@",@"0",leadID,invoiceID,web_payid];
        NSURL *url=[NSURL URLWithString:string];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
   
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[NSData dataWithData:imagedata]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString*str22 = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSString * str2=[str22 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        str2=[str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSLog(@"off sign str2....%@",str2);
        
        
        
    }
    
}
-(void)send_issue_image_to_web:(NSString *)issueId and:(NSString *)measId
{
    
    
    NSData *imageData;
    NSMutableArray *imageDataArr = [[NSMutableArray alloc]init];
    [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        
        NSString *insertSQL = [NSString stringWithFormat:@"select imageName from rst_images where webmeasurementID=%i AND imageType=4;",[measId intValue]];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                
                NSString *imagename = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imagename];
                imageData = [NSData dataWithContentsOfFile:path];
                [imageDataArr addObject:imageData];
                
                
            }
            
            
        }
        else
        {
            //////NSLog(@"problem in rst_measurement_image statement");
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    for(int i= 0;i<[imageDataArr count];i++)
    {
        
        
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        [dbSingleton() uploadReported_issues_ImageinServer:i imageData:[imageDataArr objectAtIndex:i] issueId:issueId];
        
        
    }
    
 
    
    
}



-(void)updateIssue:(NSString *)issue_id
{
    
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSString *str=[[off_issue_arr objectAtIndex:current_issue_index] objectForKey:@"webmes_id"];
        NSString *insertSQL=[NSString stringWithFormat:@"UPDATE rst_images SET issueID='%i' WHERE webmeasurementID='%i' AND imageType='%i';",[issue_id intValue],[str intValue],4];
        const char *sql = [insertSQL UTF8String];
        sqlite3_stmt *sqlStatement1;
        sqlite3_prepare_v2(database, sql, -1, &sqlStatement1, NULL);
        
        
        if(sqlite3_step(sqlStatement1)==SQLITE_DONE)
        {
            
            
        }
        else
        {
            
            // NSLog(@" insert error.....%s",sqlite3_errmsg(database));
            
        }
        
        sqlite3_finalize(sqlStatement1);
        sqlite3_close(database);
        
        
    }
    
    
}


-(void)update_rst_checklist:(NSString *)webleadid
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
       NSString *insertSQL = [NSString stringWithFormat:@"update rst_checklist set offlineFlag=0 where webleadID=%@",webleadid];
        const char * sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
            }
            
        }
        else
        {
            
            return;
            
        }
        sqlite3_finalize(compiledStatement);
    }sqlite3_close(database);
}
-(void)update_rst_estimatedTime:(NSString *)webleadid
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"update rst_estimatedTime set offlineFlag=0 where webleadID=%@",webleadid];
        const char * sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
            }
            
        }
        else{
            return;
        }
        sqlite3_finalize(compiledStatement);
    }sqlite3_close(database);
    
}

-(void)update_rst_specialinstruction:(NSString *)webleadid
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"update rst_specialinstruction set offlineFlag=0 where webleadID=%@",webleadid];
        const char * sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
            }
            
        }
        else
        {
            return;
        }
        sqlite3_finalize(compiledStatement);
    }sqlite3_close(database);
    
}





-(void)get_measurement_image_data_of_web_mid:(int)webid
{
    
    NSData *imageData;
    NSMutableArray *imageDataArr = [[NSMutableArray alloc]init];
    [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
    NSString *leadId =[dbSingleton() get_webleadid_of_webmeasurementid:webid];
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"select imageName from rst_images where webmeasurementID=%i AND imageType=0;",webid];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
            while (sqlite3_step(compiledStatement)==SQLITE_ROW) {
                
                NSString *imagename = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imagename];
                imageData = [NSData dataWithContentsOfFile:path];
                [imageDataArr addObject:imageData];
                
            }
            
        }
        else
        {
            //////NSLog(@"problem in rst_measurement_image statement");
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    for(int i= 0;i<[imageDataArr count];i++)
    {
        
            NSLog(@"imageDataArr...%i",i);
            [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
            [dbSingleton() uploadImageinServer:i+1 imageData:[imageDataArr objectAtIndex:i] webMeasurementId:webid andleadid:[leadId intValue]];
        
    }
}


-(void)get_preset_image_data_of_web_mid:(int)webid
{
    
    NSData *imageData;
    NSMutableArray *presketchimageDataArr = [[NSMutableArray alloc]init];
    NSString *leadId =[dbSingleton() get_webleadid_of_webmeasurementid:webid];
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"select imageName from rst_images where webmeasurementID=%i AND imageType=2;",webid];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                NSString *imagename = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imagename];
                imageData = [NSData dataWithContentsOfFile:path];
                [presketchimageDataArr addObject:imageData];
                
            }
            
        }
        else
        {
            //////NSLog(@"problem in rst_sketch_image_query statement");
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    for(int i= 0;i<[presketchimageDataArr count];i++)
    {
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        [dbSingleton() uploadpreset_ImageinServer:i+1 imageData:[presketchimageDataArr objectAtIndex:i] webMeasurementId:webid andleadid:[leadId intValue]];
    }
    
}


-(void)get_sketch_image_data_of_web_mid:(int)webid
{
    NSData *imageData;
    NSMutableArray *sketchimageDataArr = [[NSMutableArray alloc]init];
    NSString *leadId =[dbSingleton() get_webleadid_of_webmeasurementid:webid];
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"select imageName from rst_images where webmeasurementID=%i AND imageType =1;",webid];
        const char *sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL)==SQLITE_OK) {
            while (sqlite3_step(compiledStatement)==SQLITE_ROW)
            {
                
                NSString *imagename = [NSString stringWithFormat:@"%s",(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *path = [NSString stringWithFormat:@"%@/%@",[dbSingleton() applicationDocumentsDirectory],imagename];
                imageData = [NSData dataWithContentsOfFile:path];
                [sketchimageDataArr addObject:imageData];
                
            }
            
        }
        else
        {
            //////NSLog(@"problem in rst_sketch_image_query statement");
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    for(int i= 0;i<[sketchimageDataArr count];i++)
    {
        [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
        [dbSingleton() uploadsketch_ImageinServer:i+1 imageData:[sketchimageDataArr objectAtIndex:i] webMeasurementId:webid andleadid:[leadId intValue]];
    }
}


-(void)setwebMid_in_measurementTable:(int)wid localMeasuermentid:(int)l_mid
{
    
  
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        NSString * insertSQL = [NSString stringWithFormat:@"update rst_images set webmeasurementID=%d where localMeasurementID=%d", wid,l_mid];
        const char * sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement;
        
        sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
        if(sqlite3_step(compiledStatement)==SQLITE_DONE)
        {
            
            
        }
        else
        {
            
            // NSLog(@" insert error.....%s",sqlite3_errmsg(database));
            
        }
        sqlite3_finalize(compiledStatement);
        sqlite3_close(database);
    }sqlite3_close(database);
   
}



-(void)setwebMeasurementidfornewMeasument:(int)wid localMeasuermentid:(int)l_mid
{
    
    if (sqlite3_open([databasePath UTF8String], &database)==SQLITE_OK)
    {
        
        
        NSString * insertSQL = [NSString stringWithFormat:@"update rst_lead_measurement_info set webMesurementID=%d, offlineUpdatedFlag= 0 where localMeasurementID=%d", wid,l_mid];
        const char * sqlStatement = [insertSQL UTF8String];
        sqlite3_stmt * compiledStatement ;
        sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
        if(sqlite3_step(compiledStatement)==SQLITE_DONE)
        {
            
            
        }
        else
        {
            
             NSLog(@" web mes insert error.....%s",sqlite3_errmsg(database));
            
        }
        
        sqlite3_finalize(compiledStatement);
        sqlite3_close(database);
    }
    
    sqlite3_close(database);
    
    
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    //Export 1 march
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Error in connection, data not updated successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [delegate OffsyncFail];
    
   
}


@end
