public with sharing class attendanceStatus {
    @AuraEnabled(cacheable=true)
    public static List<MasterMember__c> findMember() {
            return [SELECT Id,Name,Nickname__c,ArrivalStatus__c,WorkingStatus__c,Affiliation__c FROM MasterMember__c WHERE AttendanceListShow__c = true ORDER BY SortNumber__c ASC];
    }
}