/* eslint-disable no-unused-vars */
import { LightningElement,wire,track } from 'lwc';

/* 共通jsの読み込み */
import { SetListValue,ChangeText,ChangeProcess } from 'c/commonJs';

import GetUserId from '@salesforce/user/Id';

import findMyMasterMember from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyMasterMember';
import findMyDailyReport from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyDailyReport';
import findTimeStamp from '@salesforce/apex/Lwc_Find_Attendance_Controller.findTimeStamp';

/* PubSub */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';


const Today = new Date();
const TodayText = ChangeText(Today);
const TodayProcess = ChangeProcess(Today);
const UserId = GetUserId;

export default class TimeStampView extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track SelectDate = Today;
    @track SelectDateProcess = TodayProcess;
    @track SelectDateText = TodayText;

    @track MemberMasterInfo = [];
    @track TimeStampInfo = [];
    columns = [
        { label: '種類', fieldName: 'TimeStampType__c' },
        { label: 'タイムスタンプ', fieldName: 'DisplayTimeStamp__c'}
    ];

    connectedCallback() {
        this.GetMasterMember();
        /* 他のComponentに更新情報を受信 */
        registerListener('UpsertTimeStamp', this.RedrawTimeStamp, this);
        registerListener('ChangeDaily', this.RedrawTimeStamp, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    RedrawTimeStamp(SendData) {
        /* 
            タイムスタンプが今日を指している場合で
            タイムスタンプが押された表示を変える
            or
            日付検索したらその日のタイムスタンプを表示させる
        */

        if( SendData.Mode === "ChangeDate" ||
            SendData.Mode === "reload" &&
            SendData.SelectDateProcess === this.SelectDateProcess &&
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
            this.GetDailyReport();
        })

    }
   
    GetDailyReport(){
        findMyDailyReport({
            SelectDateProcess : this.SelectDateProcess,
            MemberId : this.MemberMasterInfo.Id
        })
            .then(result => {
                //console.log("タイムスタンプの日報");
                //console.log(result);

                if(result.length === 0){
                    this.TimeStampInfo= [];
                }else{
                    this.GetTimeStamp(result[0].Id);
                }
            })
    }

    GetTimeStamp(DailyReportId){
        //console.log("タイムスタンプのaっっｓタイムスタンプ");
        //console.log(DailyReportId);
        findTimeStamp({
            DailyReportId : DailyReportId,
        })
        .then(result => {
            //console.log("タイムスタンプのaタイムスタンプ");
            //console.log(result);
            this.TimeStampInfo = result;
        })
    }


}