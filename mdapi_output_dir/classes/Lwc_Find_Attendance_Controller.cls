public with sharing class Lwc_Find_Attendance_Controller {
    /* ------------------------------------------------
       myシリーズで使用：ログインユーザの情報
    ------------------------------------------------ */
    @AuraEnabled
    public static List<MasterMember__c> findMyMasterMember(Id UserId) {
        return [SELECT Id
                FROM MasterMember__c
                WHERE UserId__c = :UserId
                LIMIT 1
                ];
    }

    @AuraEnabled
    public static List<MasterMember__c> findMasterMember(Id MasterMemberId) {
        return [SELECT Id,Name,ArrivalStatus__c,WorkingStatus__c,Affiliation__c,UserId__c
                FROM MasterMember__c
                WHERE Id = :MasterMemberId];
    }

    @AuraEnabled
    public static List<MasterMember__c> findMasterMembers(String Affiliation) {
        if(Affiliation == 'All'){
            return [SELECT Id,Name,RegularTimeStart__c,RegularTimeEnd__c,UserId__c FROM MasterMember__c WHERE EmploymentState__c = '在職' ORDER BY SortNumber__c ASC];
        }else{
            return [SELECT Id,Name,RegularTimeStart__c,RegularTimeEnd__c,UserId__c FROM MasterMember__c WHERE EmploymentState__c = '在職' AND Affiliation__c = :Affiliation ORDER BY SortNumber__c ASC];
        }
    }

    @AuraEnabled
    public static List<DailyReport__c> findMyDailyReport(String SelectDateProcess,Id MemberId) {
        Date SelectDate = Date.valueOf(SelectDateProcess);
        return [SELECT Id,Date__c,DailyReportType__c,
                    ScheduledAttendanceTime__c,ScheduledLeavingTime__c,
                    AttendanceTime__c,LeavingTime__c,
                    AttendanceTimeSelection__c,DisplayTimeStampAttendanceTime__c,
                    LeavingTimeSelection__c,DisplayTimeStampLeavingTime__c,
                    HolidayWorkTime__c,MidnightTimeHour__c,OverTimeHour__c,ActualTime__c,BreakTimeSelection__c,
                    MasterMemberId__r.Id,MasterMemberId__r.Name
                    FROM DailyReport__c
                    WHERE Date__c = :SelectDate AND MasterMemberId__c = :MemberId];
        /*
        return [SELECT Id,HolidayWorkTime__c,MidnightTimeHour__c,OverTimeHour__c,ActualTime__c,BreakTimeSelection__c,DailyReportType__c,Date__c,MemberId__r.Id,MemberId__r.Name,AttendanceTime__c,LeavingTime__c,
                        DisplayTimeStampAttendanceTime__c,DisplayTimeStampLeavingTime__c,Week__c
                    FROM DailyReport__c
                    WHERE Date__c = :SelectDate AND MemberId__c = :MemberId];
        */
    }

    @AuraEnabled
    public static List<DailyReport__c> findDailyReport(String StartDateProcess,String EndDateProcess,Id MemberId) {
        Date StartDate = Date.valueOf(StartDateProcess);
        Date EndDate = Date.valueOf(EndDateProcess);
       return [SELECT Id,Date__c,DailyReportType__c,
                    ScheduledAttendanceTime__c,ScheduledLeavingTime__c,
                    AttendanceTime__c,LeavingTime__c,
                    AttendanceTimeSelection__c,DisplayTimeStampAttendanceTime__c,
                    LeavingTimeSelection__c,DisplayTimeStampLeavingTime__c,
                    HolidayWorkTime__c,MidnightTimeHour__c,OverTimeHour__c,ActualTime__c,BreakTimeSelection__c,
                    MasterMemberId__r.Id,MasterMemberId__r.Name
                    FROM DailyReport__c
                    WHERE Date__c >= :StartDate AND Date__c <= :EndDate AND MasterMemberId__c = :MemberId];
    }

    @AuraEnabled
    public static String upsertDailyReport(List<DailyReport__c> UpsertList) {
        upsert UpsertList DailyReport__c.Fields.Id;
        return 'OK';
    }

    @AuraEnabled
    public static List<TimeStamp__c> findTimeStamp(Id DailyReportId) {
        if(DailyReportId == null){
            return new List<TimeStamp__c>();
        }
        return [SELECT Id,CreatedDate,TimeStampType__c,DisplayTimeStamp__c FROM TimeStamp__c WHERE DailyReportId__c = :DailyReportId ORDER BY CreatedDate DESC ];
    }

    /* 行動検索 */
    @AuraEnabled
    public static List<Event> findEvent(String SelectDateProcess,Id UserID) {
        Date SelectDate = Date.valueOf(SelectDateProcess);
        return [SELECT Id,Subject,ActivityDate,Type,StartDateTime,EndDateTime,DurationInMinutes,
                    IsAllDayEvent,StartTime__c,EndTime__c
                    FROM Event
                    WHERE ActivityDate = :SelectDate AND OwnerId =:UserID
                    ORDER BY IsAllDayEvent DESC, StartDateTime ASC
        ];
    }
    
}