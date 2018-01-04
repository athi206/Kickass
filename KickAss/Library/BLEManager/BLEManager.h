//
//  BLEManager.h
//  BLEManager
//
//  Created by TTC on 16/1/20.
//  Copyright © 2016年 TTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceInfo.h"
#import <UIKit/UIKit.h>
#import "oad.h"

typedef void (^GetRssiBlock) (NSNumber *RSSI);

typedef void(^Get_Version_Block )(NSString *string);

typedef void(^OAD_PROGRESS_Block)(float progress, NSError *error);

/**
 *  oad upgrade type
 */
typedef NS_ENUM(NSInteger, Oad_Upgrade_Type) {
    Oad_Upgrade_2541_A_or_B = 0,        //CC2541 OAD
    Oad_Upgrade_2541_Big_Capacity,      //CC2541 Large Image OAD
    Oad_Upgrade_2640_On_Chip,           //CC2640 On_Chip OAD
    Oad_Upgrade_2640_Off_Chip,          //CC2640 Off-Chip OAD
    Oad_Upgrade_2640_R1_R2              //2640 R1/R2 OAD
};

/**
 *  bin where the file exists
 */
typedef NS_ENUM(NSInteger, OAD_Bin_File_Location){
    OAD_Bin_File_ON_Project = 1,        //Bin file in the project
    OAD_Bin_File_Document               //Bin file in the sandbox directory
};

/**
 *  1004 Returns the type of data
 */
typedef NS_ENUM(NSInteger, ReceiveData_Type_1004) {
    ReceiveData_Type_1004_Version = 0,      //The version of the device
    ReceiveData_Type_1004_Battery,          //Electricity
    ReceiveData_Type_1004_UTFTime,          //clock
    ReceiveData_Type_1004_ChannelRates,     //Baud rate
    ReceiveData_Type_1004_TXPower,          //TX transmit power
    ReceiveData_Type_1004_SettingName,      //name
    ReceiveData_Type_1004_SettingPassword,  //Match the password
    ReceiveData_Type_1004_AdvertInterval,   //Broadcast interval
    ReceiveData_Type_1004_ConnectInterval,  //Connection interval
    ReceiveData_Type_1004_Latency,          //Slave delay
    ReceiveData_Type_1004_ConnectTimeOut,   //Connection timeout interval
    ReceiveData_Type_1004_AdvertData        //Broadcast data
};

@protocol BLEManagerDelegate <NSObject>

@optional

/**
 *  Bluetooth control center status callback
 *
 *  @param state: 0=unknown   1=Reset   2=It does not support Bluetooth 4.0    3=Not authorized   4= Bluetooth mobile phone Close   5=Bluetooth mobile phone open
 */
- (void)centerManagerStateChange:(CBManagerState)state;

/**
 *  Search equipment to the callback method
 *
 *  @param array: Device array
 */
- (void)scanDeviceRefrash:(NSMutableArray *)array;

- (void)bleManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

/**
 *  Connect device successfully callback method
 *
 *  @param device: Device Object
 *  @param error : Error Message
 */
- (void)connectDeviceSuccess:(CBPeripheral *)device error:(NSError *)error;

/**
 *  Disconnect the device success callback
 *
 *  @param device: vDevice Object
 *  @param error:  Error Message
 */
- (void)didDisconnectDevice:(CBPeripheral *)device error:(NSError *)error;

/**
 *  Data received callback method (1002 channels)
 *
 *  @param data:   data
 *  @param device: Device Object
 */
- (void)receiveDeviceDataSuccess_1:(NSData *)data device:(CBPeripheral *)device;

/**
 *  Data received callback method (1003 channels)
 *  @param data:   data
 *  @param device: Device Object
 */
- (void)receiveDeviceDataSuccess_3:(NSData *)data device:(CBPeripheral *)device;

- (void) Receive_Data_EventfromModel:(NSData *)TXP p:(UInt8)len DEV:(CBPeripheral *)cb AndMarkId:(NSInteger)markId;

/**
 *  @param fileType : Type Select OAD to upgrade the file, select the parameter fileType A version bin file A version bin file when you select B when B
 */
- (void)didCanSelectOADFileWithFileType:(char)fileType;

/**
 *  OAD progress of the upgrade process to send the file callback
 *
 *  @param filePer: Progress values sent documents
 */
- (void)returnSendOADFileProgressWith:(float)filePer;

/**
 *  OAD upgrade success callback
 */
- (void)returnSendOADSuccess;

/**
 *  OAD upgrade failed callback
 */
- (void)returnSendOADFailure;

/**
 *  Stop searching callback
 */
- (void)stopScanDevice;

/**
 *  Gets the callback of the value of the description under the feature (descriptor.value)
 */
- (void)receiveDeviceDescriptorValue:(NSString *)data withCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral;

/**
 *  Gets a callback after the value of a feature under a service of the specified device
 */
- (void)bleManagerPeripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 *  Send a successful callback to the data
 */
- (void)bleManagerPeripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 *  Update the notification status of the Characteristic
 */
- (void)bleManagerPeripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;


#pragma mark - extra(common)
/**
 *  Reading device version callback method
 *
 *  @param version: Version Information
 *  @param device:  device
 */
- (void)receiveDeviceVersion:(NSString *)version device:(CBPeripheral *)device;

/**
 *  Reading apparatus power callback method
 *
 *  @param battery: Power value
 *  @param device:  device
 */
- (void)receiveDeviceBattery:(NSInteger)battery device:(CBPeripheral *)device;

/**
 *  Reading device clock registers callback methods
 *
 *  @param year:   year
 *  @param month:  month
 *  @param day :   day
 *  @param hour :  time
 *  @param monute: minute
 *  @param second: seconde
 *  @param device: device
 */
- (void)receiveDeviceUTFTime:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)monute second:(NSInteger)second device:(CBPeripheral *)device;

/**
 *  Reading device baud callback method
 *
 *  @param rate:   Baud Rate  9600bps   19200bps   38400bps   57600bps   115200bps
 *  @param device: device
 */
- (void)receiveDeviceChannelRate:(NSString *)rate device:(CBPeripheral *)device;

/**
 *  Reading device transmit power TX callback method
 *
 *  @param txPower:  TX transmit power -23dbm  -6dbm  0dbm  4dbm
 *  @param device:  device
 */
- (void)receiveDeviceTXPower:(NSString *)txPower device:(CBPeripheral *)device;

/**
 *  Reading device name callback method
 *
 *  @param name:   device name
 *  @param device: device object
 */
- (void)receiveDeviceSettingName:(NSString *)name device:(CBPeripheral *)device;

/**
 *  Reading device password callback method
 *
 *  @param password: Setting a passcode
 *  @param device:  device object
 */
- (void)receiveDeviceSettingPassword:(NSString *)password device:(CBPeripheral *)device;

/**
 *  Reading apparatus broadcast interval callback method
 *
 *  @param interval: Broadcast interval (unit: ms)
 *  @param device :  device object
 */
- (void)receiveDeviceAdvertInterval:(NSInteger)interval device:(CBPeripheral *)device;

/**
 *  Reading device connection interval callback method
 *
 *  @param interval: Connection interval(unit: ms)
 *  @param device :  device object
 */
- (void)receiveDeviceConnectInterval:(NSInteger)interval device:(CBPeripheral *)device;

/**
 *  Reading device slave delay interval callback method
 *
 *  @param interval: The delay time (unit: ms)
 *  @param device :  device object
 */
- (void)receiveDeviceLatency:(NSInteger)interval device:(CBPeripheral *)device;

/**
 *  Reading device connection timeout callback method
 *
 *  @param interval: Connection outtime (unit: ms)
 *  @param device:   device object
 */
- (void)receiveDeviceConnectTimeOut:(NSInteger)interval device:(CBPeripheral *)device;

/**
 *  Broadcast data reading device callback method
 *
 *  @param dataStr: Device broadcast data
 *  @param device : device object
 */
- (void)receiveDeviceAdvertData:(NSString *)dataStr device:(CBPeripheral *)device;

/**
 *  Read the callback method of the signal of the connected device
 */
- (void)readDeviceRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;


#pragma mark - 180A
/**
 *  Get the callback method of the device module model information
 */
- (void)receiveDeviceInfoModel:(NSString *)string withDevice:(CBPeripheral *)cb;

/**
 *  The 180A service returns the callback of the data
 */
- (void)receiveDeviceInfomation:(NSString *)string withPeripheral:(CBPeripheral *)cb;


#pragma mark - 2000
- (void)receiveData:(NSData *)data with2000ServiceDevice:(CBPeripheral *)cb withCharacteristic:(CBCharacteristic *)characteristic;


@end


@interface BLEManager : NSObject

@property (nonatomic, strong) id <BLEManagerDelegate> delegate;

@property (nonatomic, strong) GetRssiBlock getRssiBlock;

@property (nonatomic, strong) Get_Version_Block getVersionBlock;

@property (nonatomic, strong) CBCentralManager* centralManager;

/**
 *  Whether the data needs to be encrypted, the encryption by default, if no encryption, set isEncryption set to NO
 */
@property (nonatomic, assign) BOOL isEncryption;

@property (nonatomic, assign) NSInteger getIder;

@property (nonatomic, strong) NSMutableArray * dev_DICARRAY;


/**
 * Examples of Bluetooth-managed single object methods
 */
+ (BLEManager *)defaultManager;

/**
 *  Search for devices
 *
 *  @param interval: Search interval
 */
- (void)scanDeviceTime:(NSInteger)interval;

/**
 *  Manually stop the search appliance
 */
- (void)manualStopScanDevice;

/**
 *  Stop the method of automatic connection
 */
- (void)stopAutoConnect;

/**
 *  Automatic connection method
 */
- (void)startAutoConnect:(NSArray *)peripheralArray;

/**
 *  Get the name of the device
 *
 *  @param device: device object
 *
 *  @return Device Name
 */
- (NSString *)getDeviceName:(CBPeripheral *)device;

/**
 *  Gets whether the device is connected
 *
 *  @param devic: device object
 *
 *  @return YES Connected  NO Not connected
 */
- (BOOL)readDeviceIsConnect:(CBPeripheral *)device;

/**
 *  Get device’s UUID
 *
 *  @param device: device object
 *
 *  @return device's UUID
 */
- (NSString *)readDeviceUUID:(CBPeripheral *)device;

/**
 *  Connected devices
 *
 *  @param device :    device object
 */
- (void)connectToDevice:(CBPeripheral *)device;

/**
 *  Disconnect the device
 *
 *  @param device: device object
 */
- (void)disconnectDevice:(CBPeripheral *)device;

/**
 *  Get device object based on the device object
 *
 *  @param uuid: device's UUID
 *
 *  @return return device object
 */
- (CBPeripheral *)getDeviceByUUID:(NSString *)uuid;

/**
 *  @param peripheral   Bluetooth object
 *  @param serviceUUID  service UUID     eg:0x1000;
 *  @param characteruisticUUID   characteruistic UUID       eg:0x1001;
 *  @param encryption   Whether it is encrypted;
 @  @param response     Write the way of writing      response = YES (CBCharacteristicWriteWithResponse)
 response = NO (CBCharacteristicWriteWithoutResponse)
 */
- (void)bleManagerPeripheral:(CBPeripheral *)peripheral writeValue:(NSString *)string serviceUUID:(UInt16)serviceUUID characteruisticUUID:(UInt16)characteruisticUUID encryption:(BOOL)encryption response:(BOOL)response;

/**
 *  set device notify state
 *
 *  @param serviceUUID service UUID   eg:(0x1000)
 *  @param cUUID       characteristic UUID   eg:(0x1001)
 *  @param device      device object
 *  @param isEnable    YES = open  NO = close
 */
- (void)notification:(UInt16)serviceUUID characteristicUUID:(UInt16)cUUID peripheral:(CBPeripheral *)device enableState:(BOOL)isEnable;




#pragma mark - 1000
/**
 *  Send data (1001)
 *
 *  @param dataStr: Hexadecimal strings
 *  @param device:  device object
 */
- (void)sendDataToDevice1:(NSString *)dataStr device:(CBPeripheral *)device;

- (void)sendData:(NSString *)dataString peripheral:(CBPeripheral *)peripheral responseState:(BOOL)state;

/**
 *  Send data (1003)
 *
 *  @param dataStr: Hexadecimal strings
 *  @param device:  device object
 */
- (void)sendDataToDevice3:(NSString *)dataStr device:(CBPeripheral *)device;

/**
 * Read 1004 channel data
 */
- (void)readDataWithDevice4:(CBPeripheral *)device;

/**
 * Send data, 1005 channels
 */
- (void)sendDataToDevice5:(NSString *)dataStr device:(CBPeripheral *)device;

/**
 *  Open the device notify channel
 *
 *  @param device device object
 */
- (void)enableNotify:(CBPeripheral *)device;

/**
 *  Close the device notify channel
 *
 *  @param device: device object
 */
- (void)disableNotify:(CBPeripheral *)device;

/**
 *  Clear device data
 */
- (void)clearDeviceData;

/**
 *  Get control center status
 *
 *  @return state 0=unknown   1=Reset   2=It does not support Bluetooth 4.0    3=Not authorized   4= Bluetooth mobile phone Close   5=Bluetooth mobile phone open
 */
- (NSInteger)readCenterManagerState;



#pragma mark - 2000

/**
 * Write data to the 2000 service channel
 * @param UUID: For example, write data to the 2001 channel, then the value is 0x2001
 */
- (void)sendData:(NSString *)string to2000ServiceDevice:(CBPeripheral *)peripheral WithCharacteristic:(UInt16)UUID responseState:(BOOL)state;

/**
 * Read 2000 service device data
 * @param uuid: For example, read the 2001 channel data, then the value is 0x2001
 */
- (void)readValueWith2000ServiceDevice:(CBPeripheral *)device wihtCharacteristics:(UInt16)uuid;

/**
 * Open the notify channel of the 2000 service device
 * @param uuid: For example, open the 2001 channel notify, pass the value is 0x2001
 */
- (void)enableNotify2000ServiceDevice:(CBPeripheral *)device withcharacteristicUUID:(UInt16)uuid;



#pragma mark - extra(common)
/**
 *  The method of reading the module model
 */
- (void)readDeviceINfoModelNumberWithDevice:(CBPeripheral *)peripheral;

/**
 *  Read the software version information of the module
 */
- (void)readDeviceINfoSoftVersionWithDevice:(CBPeripheral *)peripheral getVersioBlcok:(Get_Version_Block)getVersionBlock;

/**
 *  Read device data
 *
 *  @param serviceUUID service UUID (0x1000)
 *  @param cUUID       characteristic UUID (0x1001)
 *  @param device      device object
 */
- (void)readData:(UInt16)serviceUUID characteristicUUID:(UInt16)cUUID peripheral:(CBPeripheral *)device;

/**
 *  Read the specified device version
 *
 *  @param device: device object
 */
- (void)readDeviceVersion:(CBPeripheral *)device;

/**
 *  Read the specified device power
 *
 *  @param device: device object
 */
- (void)readDeviceBattery:(CBPeripheral *)device;

/**
 *  Read the specified device's clock register
 *
 *  @param device: device object
 */
- (void)readDeviceUTFTime:(CBPeripheral *)device;

/**
 *  Read the specified device baud rate
 *
 *  @param device: device object
 */
- (void)readDeviceChannelRates:(CBPeripheral *)device;

/**
 *  Read the specified device transmit power TX
 *
 *  @param device: device object
 */
- (void)readDeviceTXPower:(CBPeripheral *)device;

/**
 *  Read Settings Specify the name of the device
 *
 *  @param device: device object
 */
- (void)readDeviceSettingName:(CBPeripheral *)device;

/**
 *  Modify the name of the specified device
 *
 *  @param name:   device's name
 *  @param device: device object
 */
- (void)setDeviceName:(NSString *)name device:(CBPeripheral *)device;

/**
 *  Read passkey specified device settings
 *
 *  @param device : device object
 */
- (void)readDeviceSettingPassword:(CBPeripheral *)device;

/**
 *  Modify passkey specified device settings
 *
 *  @param password: The range of six-digit password (000000-999999) between
 *  @param device:   device object
 */
- (void)setDevicePassword:(NSString *)password device:(CBPeripheral *)device;

/**
 *  Read the specified device broadcast interval (32-24000 units, 625us)
 *
 *  @param device: device object
 */
- (void)readDeviceAdvertInterval:(CBPeripheral *)device;

/**
 *  Set the broadcast interval specified device (32-24000 units, 625us)
 *
 *  @param device: device object
 */
- (void)setDeviceAdvertDistanceData:(NSString *)advert device:(CBPeripheral *)device;

/**
 *  Read the specified device connection interval (16-3200 units, 1.25ms)
 *
 *  @param device: device object
 */
- (void)readDeviceConnectInterval:(CBPeripheral *)device;

/**
 *  Set a specific device connection interval (16-3200 units, 1.25ms)
 *
 *  @param device: device object
 */
- (void)setDeviceConnectDistanceData:(NSString *)advert device:(CBPeripheral *)device;

/**
 *  Reads the specified slave device delay (0-500ms)
 *
 *  @param device: device object
 */
- (void)readDeviceLatency:(CBPeripheral *)device;

/**
 *  Read the specified device connection timeout interval (0-1000ms)
 *
 *  @param device: device object
 */
- (void)readDeviceConnectTimeOut:(CBPeripheral *)device;

/**
 *  Read the specified device data broadcast
 *
 *  @param device: device object
 */
- (void)readDeviceAdvertData:(CBPeripheral *)device;

/**
 *  Sets the specified device data broadcast
 *
 *  @param advert: data broadcast
 *  @param device: device object
 */
- (void)setDeviceAdvertData:(NSString *)advert device:(CBPeripheral *)device;

/**
 * Method of obtaining device signal
 */
- (void)readDeviceRSSI:(CBPeripheral *)cb getRssiBlock:(GetRssiBlock)getRssiBlock;

- (void)readDeviceRSSI:(CBPeripheral *)cb;



#pragma mark - OAD

/**
 *  OAD upgrade type 
 *  Oad_Upgrade_2541_A_or_B = 0,        //CC2541 OAD
 *  Oad_Upgrade_2541_Big_Capacity,      //CC2541 Large Image OAD
 *  Oad_Upgrade_2640_On_Chip,           //CC2640 On_Chip OAD
 *  Oad_Upgrade_2640_Off_Chip,          //CC2640 Off-Chip OAD
 *  Oad_Upgrade_2640_R1_R2              //2640 R1/R2 OAD
 */
@property (nonatomic, assign) Oad_Upgrade_Type oad_type;

/**
 *  Oad when the interval to send data to upgrade
 */
@property (nonatomic, assign) float sendOadDataInteral;

@property (nonatomic, strong) OAD_PROGRESS_Block oadProgressBlock;

/**
 * OAD whether to cancel the upgrade, if you want to stop the ongoing OAD to upgrade the canceled set to NO
 */
@property (nonatomic,assign) BOOL canceled;

/**
 *  To oad upgrade equipment
 */
@property (nonatomic,strong) CBPeripheral * oadPeripheral;

/**
 *  Determine whether to allow oad upgrade
 *
 *  @param dev: To oad upgrade equipment
 */
- (BOOL)judgeCanOADWith:(CBPeripheral *)dev;

/**
 *  Open the OAD upgrade channel
 *
 *  @param cb : oad upgrade device (As long as judegeCanOADWith: return YES after calling this method)
 *  Open the OAD upgrade channel is successful, if it is 2541 A, B version of the upgrade will call didCanSelectOADFileWithFileType: callback method, the callback method should pass the OAD upgrade file should be selected t
 */
- (void)configureProfile:(CBPeripheral *)cb oadType:(Oad_Upgrade_Type)type;



#pragma mark - 2541 A,B版升级
/**
 * Select OAD to upgrade bin file
 *
 * @param fileName: File name oad upgrade bin file
 * If oad upgrade didCanSelectOADFileWithFileType To: call the following method * callback method inside pass arguments of type string formats such as: B version (Low) -DXM-LYD-20151215-V1.6.7.bin Or: A version (Low) -DXM -LYD-20151215-V1.6.7.bin, select a or B according to didCanSelectOADFileWithFileType: determine the type of file back callback
 
 */
- (void)startOADFileWithFileName:(NSString *)fileName filePath:(OAD_Bin_File_Location)path;



#pragma mark - 2541 Large Image OAD / 2640 off-chip OAD
- (void)enter2541BigImageOADState:(CBPeripheral *)peripheal;

/**
 *  By writing data to the specified channel, and then enter the oad mode, and then use the method startOADFileWithFileName: start the upgrade, the two modes oad upgrade do not need to choose A or B version of the bin file, this mode oad only one bin file
 */
- (void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID dataString:(NSString *)string;



#pragma mark - 2640 off-chip OAD
/**
 * @param Path : path = 1 upgrade file is placed inside the project path = 2 upgrade file in the sandbox directory under the Documents folder
 */
- (void)startOADFileWithFileName:(NSString *)fileName peripheral:(CBPeripheral *)cb filePath:(OAD_Bin_File_Location)path progressBlock:(OAD_PROGRESS_Block)block;



#pragma mark - 2640 R2 / R1 OAD
/**
 *  Enter the 2640 R1 / R2 OAD upgrade mode
 */
- (void)configure2640_R1_or_R2_OADProfile:(CBPeripheral *)cb;

/**
 *  Start 2640 R1 / R2 OAD upgrade work
 */
- (void)R1_or_R2_2640_OADStartOADWithFileName:(NSString *)fileName peripheral:(CBPeripheral *)peripheral filePath:(OAD_Bin_File_Location)path;


@end
