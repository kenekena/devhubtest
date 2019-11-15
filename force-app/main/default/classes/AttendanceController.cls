public with sharing class AttendanceController {

    // メンバーの出勤状況を取得
  @AuraEnabled
    public static void AttendanceStatus() {

        // 配列の定義
//        Data[] datas = New Data[3];

    // 各項目の定義
        String Affiliation = null;
        String MemberName = null;
        String WorkingStatus = null;

        // 有効なメンバーを取得
        List<MasterMember__c> MasterMemberList = [SELECT Id, Name, Affiliation__c, WorkingStatus__c 
                                                                    FROM MasterMember__c  
                                                      WHERE EmploymentState__c = '在職'
                                                      ORDER BY Affiliation__c,SortNumber__c ASC];
//System.debug('MasterMemberList.size　'+MasterMemberList.size());
        // 取得数分繰り返し
      for(integer i=0; MasterMemberList.size()>i; i++){
      // レコード取得
            MasterMember__c  MasterMember = MasterMemberList.get(i);
            // メンバーIDを設定
            ID MasterMemberId = MasterMember.Id;
            
            // 各ステータスを設定
            // 所属部署
            Affiliation = MasterMember.Affiliation__c;
            // 名前
            MemberName = MasterMember.name;
            // 所属部署
            WorkingStatus = MasterMember.WorkingStatus__c;
        

            // 日報識別IDを設定(日付＋関連メンバー)
      String DailyReportIdentificationId = String.valueOf(Date.today()).left(10) + MasterMemberId;

          // 日報を取得
          List<DailyReport__c> DailyReportList = [SELECT Id, DailyReportType__c  
                                                                            FROM DailyReport__c  
                                                              WHERE DailyReportIdentificationId__c = :DailyReportIdentificationId];

          String DailyReportType = null;
            if(DailyReportList.size() > 0){
        // レコード取得
              DailyReport__c  DailyReport = DailyReportList.get(0);
                // 日報種別を設定
                DailyReportType = DailyReport.DailyReportType__c;
            }

System.debug('Affiliation　'+Affiliation);
System.debug('MemberName　'+MemberName);
System.debug('WorkingStatus　'+WorkingStatus);
System.debug('DailyReportType　'+DailyReportType);
//System.debug('datas[i]　'+datas[i]);

        }
    }
}