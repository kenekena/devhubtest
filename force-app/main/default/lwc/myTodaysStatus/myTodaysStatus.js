/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement,track,wire } from 'lwc';
/* 共通jsの読み込み */
import { SetListValue,ChangeText,ChangeProcess } from 'c/commonJs';

import GetUserId from '@salesforce/user/Id';

import findMyMasterMember from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyMasterMember';
import findMyDailyReport from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyDailyReport';

/* PubSub */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';


const Today = new Date();
const TodayText = ChangeText(Today);
const TodayProcess = ChangeProcess(Today);
const UserId = GetUserId;

export default class MyTodaysStatus extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @track DailyReportInfo = [];
    @track MemberMasterInfo = [];
    connectedCallback() {
        this.GetMasterMember();

        /* 他のComponentに更新情報を受信 */
        registerListener('UpsertTimeStamp', this.UpsertTimeStamp, this);
        registerListener('ChangeDaily', this.RedrawDailyReport, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    UpsertTimeStamp() {
        /* タイムスタンプが押されたら再読み込み */
        this.GetMasterMember();
    }

    RedrawDailyReport(SendData) {
        /* メンバーIDが自分自身で今日の場合のみ更新 */
        if( SendData.Mode === "ChangeDate" &&
            SendData.SelectDateProcess === TodayProcess &&
            SendData.MemberMasterInfo.Id === this.MemberMasterInfo.Id
        ){
            /* タイムスタンプが押されたら、今日の日付に合わせる */
            this.SelectDate = SendData.SelectDate;
            this.SelectDateProcess = SendData.SelectDateProcess;
            this.SelectDateText = SendData.SelectDateText;

            this.MemberMasterInfo = SendData.MemberMasterInfo;
            this.GetDailyReport();
        }

    }

    GetMasterMember(){
        findMyMasterMember({UserId : UserId})
        .then(result => {
            this.MemberMasterInfo = result[0];
            //出勤状況表示用の分岐
            if(this.MemberMasterInfo.ArrivalStatus__c){
                this.MemberMasterInfo.ArrivalStatus="出勤中";
            }else{
                this.MemberMasterInfo.ArrivalStatus="";
            }
            console.log("findMyMasterMember");
            console.log(result);
            this.GetDailyReport();
        })

    }
   
    GetDailyReport(){
        findMyDailyReport({
            SelectDateProcess : TodayProcess,
            MemberId : this.MemberMasterInfo.Id
        })
            .then(result => {
                if(result.length === 0){
                    this.DailyReportInfo = {
                        Date__c : TodayText,
                        AttendanceTimeSelection__c : "",
                        LeavingTimeSelection__c : "",
                        DisplayTimeStampAttendanceTime__c : "",
                        DisplayTimeStampLeavingTime__c : "",
                    }
                }else{
                    this.DailyReportInfo = result[0];
                }
                this.DailyReportInfo.DateText = TodayText;
                console.log("findMyDailyReport");
                console.log(result);
            })

    }

}