trigger PaidHolidaysAuto on PaidHolidays__c (
			after insert,
            after update,
//          after delete,
//          after undelete,
//            before insert,
//            before update,
            before delete
) {
    // -----------------------------------------------------
    // カスタムメタデータ取得
    // -----------------------------------------------------
    Kyosin7Setting__mdt Kyosin7Setting = [SELECT MasterLabel, PaidHolidaysAuto__c, GetMinimumPaid__c
                                            									FROM Kyosin7Setting__mdt];
//System.debug('Kyosin7Setting__mdt　'+Kyosin7Setting.MasterLabel);
//System.debug('PaidHolidaysAuto__c　'+Kyosin7Setting.PaidHolidaysAuto__c);

    // 有給休暇自動処理がTrueの場合処理する  
    if(Kyosin7Setting.PaidHolidaysAuto__c == True){

        // after insert処理
        if (Trigger.isAfter && Trigger.isInsert) {
System.debug('PaidHolidays__c　after insert処理　');
            // ----------------------------------------------------------------------
            // 有給休暇レコード取得
            // ----------------------------------------------------------------------
            List<PaidHolidays__c> PaidHolidaysList0 = Trigger.new;
            PaidHolidays__c PaidHolidays0 = PaidHolidaysList0.get(0);
//System.debug('PaidHolidays0 　'+PaidHolidays0);
            // IDを設定
            ID PaidHolidaysId = PaidHolidays0.Id;
            // 関連メンバーを設定
            ID MasterMemberId = PaidHolidays0.MasterMemberId__c;
            // 付与年月日を設定
            Date GrantDate = PaidHolidays0.GrantDate__c;
            // 年（期）を設定
            String Period = PaidHolidays0.Period__c;
            // 付与日数を設定
            Decimal GrantDays = PaidHolidays0.GrantDays__c;
            // 繰越日数を設定
            Decimal CarryOverDays = 0;
            if(PaidHolidays0.CarryOverDays__c != null)
                CarryOverDays = PaidHolidays0.CarryOverDays__c;
            // 繰越時間を設定
            Decimal CarryOverTime = 0;
            if(PaidHolidays0.CarryOverTime__c != null)
                CarryOverTime = PaidHolidays0.CarryOverTime__c;
//System.debug('CarryOverDays 　'+CarryOverDays);
//System.debug('CarryOverTime 　'+CarryOverTime);


            // 有給休暇OBJの算出項目
            Decimal PH_RemainingGrantDays = 0;
            Decimal PH_CarryForwardDays = CarryOverDays;
            Decimal PH_CarryForwardTime = CarryOverTime;
            Decimal PH_PaidLeaveRemainingDays = 0;
            Decimal PH_PaidLeaveRemainingTime = 0;
            Decimal PH_CarryOverDays = 0;
            Decimal PH_CarryOverTime = 0;
            Decimal PH_CarryOverDigestionDays = 0;
            Decimal PH_PaidLapseDays = 0;
//System.debug('PH_CarryForwardDays 　'+PH_CarryForwardDays);
//System.debug('PH_CarryForwardTime 　'+PH_CarryForwardTime);

            // ----------------------------------------------------------------
			// 有給休暇OBJの更新処理
            // ----------------------------------------------------------------
            // 有給休暇OBJデータを取得(年（期）の降順)
			List<PaidHolidays__c> PaidHolidaysList = [SELECT Id, MasterMemberId__c,Period__c,
                                                      												GrantDays__c, GrantDate__c,
					                    	                      									RemainingGrantDays__c, RemainingGrantTime__c,
																									PaidLeaveRemainingDays__c, PaidLeaveRemainingTime__c,
																									CarryOverDays__c, CarryOverTime__c,
                                                      												CarryOverDigestionDays__c, CarryOverDigestionTime__c
                                                										FROM PaidHolidays__c
                                                										WHERE MasterMemberId__c = :MasterMemberId
                                               											ORDER BY Period__c DESC];
	        // 取得数分繰り返し
    	    for(integer i=0; PaidHolidaysList.size()>i; i++){
        	    // レコード取得
                PaidHolidays__c  PaidHolidays = PaidHolidaysList.get(i);
//System.debug('PaidHolidays 　'+PaidHolidays);

                // 最新の有休付与（日数）を設定
                if(i == 0){
                    // 有給休暇OBJ項目
                    // 付与残（日数）を設定
					PH_RemainingGrantDays = PaidHolidays.GrantDays__c;
//System.debug('PH_RemainingGrantDays 　'+PH_RemainingGrantDays);
                }

                // 付与前の有休残数を設定
                if(i == 1){
                    // 繰越消化（日数）を設定
                    // 繰越消化（日数）が有休取得義務日より少ない場合は有休取得義務日を設定
                    PH_CarryOverDigestionDays = PaidHolidays.CarryOverDigestionDays__c;
                    if(PaidHolidays.CarryOverDigestionDays__c < Kyosin7Setting.GetMinimumPaid__c )
                        PH_CarryOverDigestionDays = Kyosin7Setting.GetMinimumPaid__c;
//System.debug('繰越消化（日数） 　'+PH_CarryOverDigestionDays);
                    // 消滅日数を算出(繰越日数ー繰越消化（日数）)
                    if(PaidHolidays.CarryOverDays__c < Kyosin7Setting.GetMinimumPaid__c){
	                    PH_PaidLapseDays = PH_CarryOverDigestionDays;                        
                    }else{
                        PH_CarryOverDays = PaidHolidays.CarryOverDays__c;
	                    PH_PaidLapseDays = PH_CarryOverDays - PH_CarryOverDigestionDays;
                        if(PH_PaidLapseDays < 0)
                            PH_PaidLapseDays = 0;
                    }
//System.debug('消滅日数　'+PH_PaidLapseDays);

                    // 繰越日数を算出( 有休残日数 - 消滅日数)
                    PH_CarryOverDays = PaidHolidays.PaidLeaveRemainingDays__c - PH_PaidLapseDays;
//System.debug('繰越日数 　'+PH_CarryOverDays);

                    // 繰越残（日数）を設定(繰越日数)
                    if(PaidHolidays.CarryOverDays__c != null)
						PH_CarryForwardDays = PH_CarryForwardDays + PH_CarryOverDays;
                    // 繰越残（時間）を算出（繰越時間）
                    if(PaidHolidays.CarryOverTime__c != null)
						PH_CarryForwardTime = PH_CarryForwardTime + PaidHolidays.CarryOverTime__c;
//System.debug('繰越残（日数） 　'+PH_CarryForwardDays);
//System.debug('繰越残（時間） 　'+PH_CarryForwardTime);
                    // ループ終わり
                    break;
                }
            }
            // 有休残日数(付与残（日数）＋繰越残（日数）)
            PH_PaidLeaveRemainingDays = PH_RemainingGrantDays + PH_CarryForwardDays;
            // 有休残時間(繰越残（時間）)
            PH_PaidLeaveRemainingTime = PH_CarryForwardTime;

//System.debug('PH_PaidLeaveRemainingDays 　'+PH_PaidLeaveRemainingDays);
//System.debug('PH_PaidLeaveRemainingTime 　'+PH_PaidLeaveRemainingTime);

            // 有給休暇OBJ
	    	List<PaidHolidays__c> PaidHolidaysTMP = new List<PaidHolidays__c>();

        	// 有給休暇OBJを更新
            PaidHolidaysTMP.add(new PaidHolidays__c(
                    									Id = PaidHolidaysId,
                						                RemainingGrantDays__c = PH_RemainingGrantDays,
                						                RemainingGrantTime__c = 0,
                						                GrantDigestionDays__c = 0,
                						                GrantDigestionTime__c = 0,
                    	                				CarryOverDays__c = PH_CarryForwardDays,
                    									CarryOverTime__c = PH_CarryForwardTime,
                    	                				CarryForwardDays__c = PH_CarryForwardDays,
                    									CarryForwardTime__c = PH_CarryForwardTime,
                						                CarryOverDigestionDays__c = 0,
                						                CarryOverDigestionTime__c = 0,
                										PaidLeaveRemainingDays__c = PH_PaidLeaveRemainingDays,
                										PaidLeaveRemainingTime__c = PH_PaidLeaveRemainingTime,
                										PaidLapseDays__c = PH_PaidLapseDays,
                        								TriggerUpdate__c = True
                                   				)
	        );
            // 有給休暇OBJデータ更新
            if (PaidHolidaysTMP.size() > 0) {
                try{
System.debug('PaidHolidays__c　after insert PaidHolidaysTMP　'+PaidHolidaysTMP);
                    update PaidHolidaysTMP;
                }catch(DmlException e){
                    System.debug('PaidHoliday__c after insert1 有給休暇OBJの更新失敗');
                	Integer errNum = e.getNumDml();
                    for(Integer i = 0; i < errNum; i++){
                    	PaidHolidaysTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                    }
                }
            }

        }

        // after update処理
        if (Trigger.isAfter && Trigger.isUpdate) {
System.debug('PaidHolidays__c　after update処理　');
            // ----------------------------------------------------------------------
            // 有給休暇レコード取得
            // ----------------------------------------------------------------------
            // 変更後の有給休暇レコード取得
            List<PaidHolidays__c> PaidHolidaysList = Trigger.new;
            PaidHolidays__c PaidHolidays = PaidHolidaysList.get(0);
            ID PaidHolidaysId = PaidHolidays.Id;

//System.debug('after update PaidHolidays　'+PaidHolidays);
//System.debug('after update PaidHolidays.TriggerUpdate__c　'+PaidHolidays.TriggerUpdate__c);

            // 変更前の日報レコード取得
            List<PaidHolidays__c> PaidHolidaysListOLD = Trigger.old;
            PaidHolidays__c PaidHolidaysOLD = PaidHolidaysListOLD.get(0);

            // --------------------------------------------------------------------------------------------------------------
            // 変更前の最終更新日が前回と違う場合もしくは
            // [システム]有休申請に値が入っている場合（ループ防止）
            // --------------------------------------------------------------------------------------------------------------
            if(PaidHolidays.LastModifiedDate != PaidHolidaysOLD.LastModifiedDate ||
				PaidHolidays.PaidRequest__c != null){

                // ----------------------------------------------------------------------------------------------------------------
            	// 有給休暇OBJのトリガ以外の変更かつ変更前がデータロックの場合はエラーとする
            	// 有給休暇OBJのトリガ以外の変更かつ変更前がデータロックかつ変更後がデータロックでないの場合
            	// はエラーとする
            	// ----------------------------------------------------------------------------------------------------------------
//System.debug('after update PaidHolidays.TriggerUpdate__c　'+PaidHolidays.TriggerUpdate__c);
//System.debug('after update PaidHolidaysOLD.DataLock__c　'+PaidHolidaysOLD.DataLock__c);
//System.debug('after update PaidHolidays.DataLock__c　'+PaidHolidays.DataLock__c);
            	if(PaidHolidays.TriggerUpdate__c == True && PaidHolidaysOLD.DataLock__c == False ||
					PaidHolidays.TriggerUpdate__c == True && PaidHolidaysOLD.DataLock__c == True && PaidHolidays.DataLock__c == False){

		            // ----------------------------------------------------------------------------------
        		    // 有給休暇OBJの差分日数、差分時間を設定(NULLは０を設定)
            		// ----------------------------------------------------------------------------------
		            Decimal DifferenceDays = 0;
        		    if(PaidHolidays.DifferenceDays__c != null)
                		DifferenceDays = PaidHolidays.DifferenceDays__c;
		            Decimal DifferenceTime = 0;
        		    if(PaidHolidays.DifferenceTime__c != null)
                		DifferenceTime = PaidHolidays.DifferenceTime__c;
//System.debug('after update DifferenceDays元差分日数　'+DifferenceDays);
//System.debug('after update DifferenceTime元差分時間　'+DifferenceTime);
                
		            // ----------------------------------------------------------------------------------
        		    // 有休残、繰越残、繰越消化、付与残、付与消化を設定
		            // ----------------------------------------------------------------------------------
		            // 付与日数
					Decimal  GrantDays = PaidHolidays.GrantDays__c;
		            // 繰越日数
					Decimal  CarryOverDays = PaidHolidays.CarryOverDays__c;
		            // 繰越時間
        		    Decimal  CarryOverTime = PaidHolidays.CarryOverTime__c;
		            // 有休残日数
        		    Decimal  PaidLeaveRemainingDays = PaidHolidays.PaidLeaveRemainingDays__c;
		            // 有休残時間
        		    Decimal  PaidLeaveRemainingTime = PaidHolidays.PaidLeaveRemainingTime__c;
		            // 繰越残(日数)
        		    Decimal  CarryForwardDays = PaidHolidays.CarryForwardDays__c;
		            // 繰越残(時間)
        		    Decimal  CarryForwardTime = PaidHolidays.CarryForwardTime__c;
		            // 繰越消化(日数)
        		    Decimal  CarryOverDigestionDays = PaidHolidays.CarryOverDigestionDays__c;
		            // 繰越消化(時間)
        		    Decimal  CarryOverDigestionTime = PaidHolidays.CarryOverDigestionTime__c;
		            // 付与残(日数)
        		    Decimal  RemainingGrantDays = PaidHolidays.RemainingGrantDays__c;
		            // 付与残(時間)
        		    Decimal  RemainingGrantTime = PaidHolidays.RemainingGrantTime__c;
		            // 付与消化(日数)
        		    Decimal  GrantDigestionDays = PaidHolidays.GrantDigestionDays__c;
		            // 付与消化(時間)
        		    Decimal  GrantDigestionTime = PaidHolidays.GrantDigestionTime__c;

//System.debug('after update 有休残日数0　'+PaidLeaveRemainingDays);
//System.debug('after update 有休残時間0　'+PaidLeaveRemainingTime);
//System.debug('after update 繰越日数0　'+CarryOverDays);
//System.debug('after update 繰越時間0　'+CarryOverTime);
//System.debug('after update 繰越残(日数)0　'+CarryForwardDays);
//System.debug('after update 繰越残(時間)0　'+CarryForwardTime);
//System.debug('after update 繰越消化(日数)0　'+CarryOverDigestionDays);
//System.debug('after update 繰越消化(時間)0　'+CarryOverDigestionTime);
//System.debug('after update 付与残(日数)0　'+RemainingGrantDays);
//System.debug('after update 付与残(時間)0　'+RemainingGrantTime);
//System.debug('after update 付与消化(日数)0　'+GrantDigestionDays);
//System.debug('after update 付与消化(時間)0　'+GrantDigestionTime);

		            // -----------------------------------------------------------------------------------
        		    // 有給休暇OBJの有休申請が”申請”の場合に処理する
            		// -----------------------------------------------------------------------------------
            		if(PaidHolidays.PaidRequest__c == '申請'){
//System.debug('PaidHolidays__c　after update PaidHolidays.PaidRequest__c == 申請　');

		                // ----------------------------------------------------------------------------------
        		        // 日申請（差分日数が0より大きい）の場合
                		// ----------------------------------------------------------------------------------
		                if(DifferenceDays > 0){
System.debug('PaidHolidays__c　after update 日申請（差分日数が0より大きい）　');
        		            // 有休残日数の算出
                		    // 有休残日数 = 有休残日数 - 差分日数（減算）
		                    PaidLeaveRemainingDays = PaidLeaveRemainingDays - DifferenceDays;
//System.debug('after update 有休残日数1　'+PaidLeaveRemainingDays);

                            // 繰越残（日数）が差分日数以上の場合、繰越残（日数）から算出
                            if(CarryForwardDays >= DifferenceDays){
	                		    // 繰越残(日数) = 繰越残(日数) - 差分日数
								CarryForwardDays = CarryForwardDays - DifferenceDays;		
	                		    // 繰越消化(日数) = 繰越消化(日数) + 差分日数
								CarryOverDigestionDays = CarryOverDigestionDays + DifferenceDays;		
                            }
                            // 付与残（日数）から算出
                            else{
								// 繰越残（日数）が残ってる場合
								// 差分日数から繰越残（日数）を減算、繰越消化（日数）は、+1、繰越残（日数）は、0
                                if(CarryForwardDays > 0){
	        		            	// 差分日数 = 差分日数 - 繰越残（日数）
									DifferenceDays = DifferenceDays - CarryForwardDays;
                                    // 繰越消化（日数）=繰越消化（日数）+繰越残（日数）
									CarryOverDigestionDays =  CarryOverDigestionDays + CarryForwardDays;
                                    // 繰越残（日数）=０
                                	CarryForwardDays = 0;
                                }

	                		    // 付与残(日数) = 付与残(日数) - 差分日数
								RemainingGrantDays = RemainingGrantDays - DifferenceDays;		
	                		    // 付与消化(日数) = 付与消化(日数) + 差分日数
								GrantDigestionDays = GrantDigestionDays + DifferenceDays;		
                            }
                		}

		                // ----------------------------------------------------------------------------------
        		        // 日申請（差分日数が0より小さい）の場合(マイナス日)
                		// ----------------------------------------------------------------------------------
		                if(DifferenceDays < 0){
System.debug('PaidHolidays__c　after update 日申請（差分日数が0より小さい）　');
        		            // 有休残日数の算出
                		    // 有休残日数 = 有休残日数 - 差分日数（加算）
		                    PaidLeaveRemainingDays = PaidLeaveRemainingDays - DifferenceDays;
//System.debug('after update 有休残日数1　'+PaidLeaveRemainingDays);

//System.debug('after update GrantDigestionDays　'+GrantDigestionDays);
//System.debug('after update DifferenceDays　'+DifferenceDays);
                            // 付与消化（日数）が差分日数(プラス値に変換)以上の場合
                            // 付与残（日数）に差分日数を加算、付与消化（日数）に差分日数を減算
                            if(GrantDigestionDays >= (0 - DifferenceDays)){
	                            // 付与残（日数） = 付与残（日数） - 差分日数
//System.debug('after update RemainingGrantDays　'+RemainingGrantDays);
								RemainingGrantDays = RemainingGrantDays - DifferenceDays;
//System.debug('after update RemainingGrantDays　'+RemainingGrantDays);
//System.debug('after update GrantDays　'+GrantDays);

	                            // 算出した付与残（日数）が付与日数より大きい場合
	                            // 繰越残（日数）に差分日数を加算、繰越消化（日数）に差分日数を減算
	                            // 付与残（日数）に付与日数を設定、付与消化（日数）に０を設定
    	                        if(RemainingGrantDays > GrantDays){
        	                        // 差分日数を算出（付与残（日数）+付与日数）
            	                    DifferenceDays = RemainingGrantDays + GrantDays;

	                                // 繰越残（日数）に差分日数を加算
									CarryForwardDays = CarryForwardDays - DifferenceDays;
        	                        // 繰越消化（日数）から差分日数を減算
									CarryOverDigestionDays = CarryOverDigestionDays + DifferenceDays;

	            	                // 付与残（日数）=付与日数
                    	            RemainingGrantDays = GrantDays;
	                    	        // 付与消化（日数）=0
                            	    GrantDigestionDays = 0;
                            	}
	                            // 算出した付与残（日数）が付与日数以下の場合
	                            // 付与消化（日数）に差分日数を減算
	                            else{
    	                            // 付与消化（日数） = 付与消化（日数） + 差分日数
									GrantDigestionDays = GrantDigestionDays + DifferenceDays;
            	                }
                            }
                            // 付与消化（日数）が差分日数(プラス値に変換)より小さい場合
	                        // 繰越残（日数）に差分日数を加算、繰越消化（日数）に差分日数を減算
                            else{
                                // 付与消化（日数）が0以外は付与消化（日数）から減算
                                if(GrantDigestionDays > 0){
        	                        // 差分日数を算出（差分日数+付与消化（日数））
            	                    DifferenceDays = DifferenceDays + GrantDigestionDays;
                                    
	            	                // 付与残（日数）=付与残（日数）+付与消化（日数）
                    	            RemainingGrantDays = RemainingGrantDays + GrantDigestionDays;
                                    // 付与消化（日数）に0を設定
                                    GrantDigestionDays = 0;
                                }
                                
	                            // 繰越残（日数）に差分日数を加算
								CarryForwardDays = CarryForwardDays - DifferenceDays;
        	                    // 繰越消化（日数）から差分日数を減算
								CarryOverDigestionDays = CarryOverDigestionDays + DifferenceDays;

                                // 繰越残（日数）が1以上かつ付与残（時間）が１以上の場合
                                // 繰越残（日数）-1
                                // 繰越残（時間）=付与残（時間）、繰越消化（時間）=付与消化（時間）
                                // 付与残（日数）+1、付与残（時間）=0、付与消化（時間）=0
//System.debug('after update CarryForwardDays　'+CarryForwardDays);
//System.debug('after update RemainingGrantTime　'+RemainingGrantTime);
                                iF(CarryForwardDays >= 1 && RemainingGrantTime >= 1){
	                                // 繰越残（日数）-1
	                                CarryForwardDays = CarryForwardDays -1;
	                                // 繰越残（時間）=付与残（時間）
	                                CarryForwardTime = RemainingGrantTime;
	                                // 繰越消化（時間）=付与消化（時間）
	                                CarryOverDigestionTime = GrantDigestionTime;
	                                // 付与残（日数）-1
	                                RemainingGrantDays = RemainingGrantDays +1;
	                                // 付与残（時間）=0
	                                RemainingGrantTime = 0;
	                                // 付与消化（時間）=0
	                                GrantDigestionTime = 0;
                                    
                                }
                            }
                            
                        }

//System.debug('after update 繰越残(日数)1　'+CarryForwardDays);
//System.debug('after update 繰越消化(日数)1　'+CarryOverDigestionDays);
//System.debug('after update 付与残(日数)1　'+RemainingGrantDays);
//System.debug('after update 付与消化(日数)1　'+GrantDigestionDays);

                        // ----------------------------------------------------------------------------------
        		        // 時間申請（差分時間が0より大きい）の場合
                		// ----------------------------------------------------------------------------------
                		if(DifferenceTime > 0){
System.debug('PaidHolidays__c　after update 時間申請（差分時間が0より大きい）　');
		                    // 有休残時間の算出
        		            // 有休残時間 = 有休残時間 - 差分時間
                		    PaidLeaveRemainingTime = PaidLeaveRemainingTime - DifferenceTime;
//System.debug('after update 有休残時間1　'+PaidLeaveRemainingTime);

		                    // 算出した有休残時間が８以上の場合、有休残日数+1して有休残時間-8する
        		            if(PaidLeaveRemainingTime >= 8){
                		            // 有休残日数=有休残日数+1
                        		    PaidLeaveRemainingDays =  PaidLeaveRemainingDays +1;
		                            // 有休残時間=有休残時間-8
        		                    PaidLeaveRemainingTime = PaidLeaveRemainingTime - 8;
                		    }
                        
	                    	// 有休残時間がマイナスになった場合、有休残日数-1して有休残時間+8する
		    	            if(PaidLeaveRemainingTime < 0){
        			            // 有休残日数=有休残日数-1
            		            PaidLeaveRemainingDays = PaidLeaveRemainingDays -1;
               	    		    // 有休残時間=有休残時間+8
                   	    		PaidLeaveRemainingTime = PaidLeaveRemainingTime + 8;
                   			}

//System.debug('after update CarryForwardTime　'+CarryForwardTime);
//System.debug('after update DifferenceTime　'+DifferenceTime);
                            // 繰越残（時間）が差分時間以上の場合　または
                            // 繰越残（時間）が差分時間より小さいかつ繰越残（日数）が1以上の場合
                            // 繰越残（時間）から算出
                            if(CarryForwardTime >= DifferenceTime ||
								(CarryForwardTime < DifferenceTime && CarryForwardDays >= 1)){

    	    		            // 繰越残（時間） = 繰越残（時間） - 差分時間
        	        		    CarryForwardTime = CarryForwardTime - DifferenceTime;

		    	                // 算出した繰越残（時間）が８以上の場合、繰越残（日数）+1して繰越残（時間）-8する
        			            if(CarryForwardTime >= 8){
                			            // 繰越残（日数）=繰越残（日数）+1
                        			    CarryForwardDays =  CarryForwardDays +1;
		                    	        // 繰越残（時間）=繰越残（時間）-8
        		                	    CarryForwardTime = CarryForwardTime - 8;
                		    	}

                                // 繰越残（時間）がマイナスになった場合、繰越残（日数）-1して繰越残（時間）+8する
			    	            if(CarryForwardTime < 0){
    	    			            // 繰越残（日数）=繰越残（日数）-1
        	    		            CarryForwardDays = CarryForwardDays -1;
            	   	    		    // 繰越残（時間）=繰越残（時間）+8
                	   	    		CarryForwardTime = CarryForwardTime + 8;
                   				}

		                	    // 繰越消化（時間）の算出
        		            	// 繰越消化（時間） = 繰越消化（時間） + 差分時間
	                		    CarryOverDigestionTime = CarryOverDigestionTime + DifferenceTime;

			                    // 算出した繰越消化（時間）が８以上の場合、繰越消化（日数）+1して繰越消化（時間）-8する
        			            if(CarryOverDigestionTime >= 8){
            	    		            // 繰越消化（日数）=繰越消化（日数）+1
                	        		    CarryOverDigestionDays =  CarryOverDigestionDays +1;
		            	                // 繰越消化（時間）=繰越消化（時間）-8
        		        	            CarryOverDigestionTime = CarryOverDigestionTime - 8;
                		    	}

		                    	// 繰越消化（時間）がマイナスになった場合、繰越消化（日数）-1して繰越消化（時間）+8する
			    	            if(CarryOverDigestionTime < 0){
        				            // 繰越消化（日数）=繰越消化（日数）-1
            			            CarryOverDigestionDays = CarryOverDigestionDays -1;
               		    		    // 繰越消化（時間）=繰越消化（時間）+8
                   		    		CarryOverDigestionTime = CarryOverDigestionTime + 8;
                   				}
//System.debug('after update 繰越残(時間)1　'+CarryForwardTime);
//System.debug('after update 繰越消化(時間)1　'+CarryOverDigestionTime);

                            }
                            // 繰越残（時間）が差分時間より小さいかつ繰越残（日数）が1より小さい場合
			                // 付与残（時間）から算出
                            else{
//System.debug('after update CarryForwardTime　'+CarryForwardTime);
//System.debug('after update DifferenceTime　'+DifferenceTime);
//System.debug('after update CarryOverDigestionDays　'+CarryOverDigestionDays);
								// 繰越残（時間）が残ってる場合、差分時間から繰越残（時間）を減算
								// 繰越消化（時間）=0、繰越残（時間）= 0
                                if(CarryForwardTime > 0){
	        		            	// 差分時間 = 差分時間 - 繰越残（時間）
									DifferenceTime = DifferenceTime - CarryForwardTime;

		    	        	        // 繰越消化（時間）=繰越消化（時間）+繰越残（時間）
        			        	    CarryOverDigestionTime = CarryOverDigestionTime + CarryForwardTime;
									// 繰越残（時間）= 0
                                	CarryForwardTime = 0;
                                }

//System.debug('after update RemainingGrantTime　'+RemainingGrantTime);
//System.debug('after update DifferenceTime　'+DifferenceTime);
                                // 付与残（時間） = 付与残（時間） - 差分時間
        	        		    RemainingGrantTime = RemainingGrantTime - DifferenceTime;
//System.debug('after update 付与残(時間)1　'+RemainingGrantTime);

		    	                // 算出した付与残（時間）が８以上の場合、付与残（日数）+1して付与残（時間）-8する
        			            if(RemainingGrantTime >= 8){
                			            // 付与残（日数）=付与残（日数）+1
                        			    RemainingGrantDays =  RemainingGrantDays +1;
		                    	        // 付与残（時間）=付与残（時間）-8
        		                	    RemainingGrantTime = RemainingGrantTime - 8;
                		    	}

                                // 付与残（時間）がマイナスになった場合、付与残（日数）-1して付与残（時間）+8する
			    	            if(RemainingGrantTime < 0){
    	    			            // 付与残（日数）=付与残（日数）-1
        	    		            RemainingGrantDays = RemainingGrantDays -1;
            	   	    		    // 付与残（時間）=付与残（時間）+8
                	   	    		RemainingGrantTime = RemainingGrantTime + 8;
                   				}

		                	    // 付与消化（時間）の算出
        		            	// 付与消化（時間） = 付与消化（時間） + 差分時間
	                		    GrantDigestionTime = GrantDigestionTime + DifferenceTime;
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);

			                    // 算出した付与消化（時間）が８以上の場合、付与消化（日数）+1して付与消化（時間）-8する
        			            if(GrantDigestionTime >= 8){
            	    		            // 付与消化（日数）=付与消化（日数）+1
                	        		    GrantDigestionDays =  GrantDigestionDays +1;
		            	                // 付与消化（時間）=付与消化（時間）-8
        		        	            GrantDigestionTime = GrantDigestionTime - 8;
                		    	}

		                    	// 付与消化（時間）がマイナスになった場合、付与消化（日数）-1して付与消化（時間）+8する
			    	            if(GrantDigestionTime < 0){
        				            // 付与消化（日数）=付与消化（日数）-1
            			            GrantDigestionDays = GrantDigestionDays -1;
               		    		    // 付与消化（時間）=付与消化（時間）+8
                   		    		GrantDigestionTime = GrantDigestionTime + 8;
                   				}
                            }
//System.debug('after update 付与残(時間)2　'+RemainingGrantTime);
//System.debug('after update 付与消化(時間)2　'+GrantDigestionTime);
                        }
                        
                        // ----------------------------------------------------------------------------------
        		        // 時間申請（差分時間が0より小さい）の場合
                		// ----------------------------------------------------------------------------------
                		if(DifferenceTime < 0){
System.debug('PaidHolidays__c　after update 時間申請（差分時間が0より小さい）　');
		                    // 有休残時間の算出
        		            // 有休残時間 = 有休残時間 - 差分時間
                		    PaidLeaveRemainingTime = PaidLeaveRemainingTime - DifferenceTime;
//System.debug('after update 有休残時間1　'+PaidLeaveRemainingTime);

		                    // 算出した有休残時間が８以上の場合、有休残日数+1して有休残時間-8する
        		            if(PaidLeaveRemainingTime >= 8){
                		            // 有休残日数=有休残日数+1
                        		    PaidLeaveRemainingDays =  PaidLeaveRemainingDays +1;
		                            // 有休残時間=有休残時間-8
        		                    PaidLeaveRemainingTime = PaidLeaveRemainingTime - 8;
                		    }
                        
	                    	// 有休残時間がマイナスになった場合、有休残日数-1して有休残時間+8する
		    	            if(PaidLeaveRemainingTime < 0){
        			            // 有休残日数=有休残日数-1
            		            PaidLeaveRemainingDays = PaidLeaveRemainingDays -1;
               	    		    // 有休残時間=有休残時間+8
                   	    		PaidLeaveRemainingTime = PaidLeaveRemainingTime + 8;
                   			}

			                // 付与残（時間）の算出
                            // 付与残（日数）が(付与日数-1.0)以下かつ算出した付与残(時間)が8より小さい場合
                            // 付与残（時間）から算出
                            if(RemainingGrantDays <= GrantDays-1.0 && 8 > (RemainingGrantTime-DifferenceTime)){

                                // 付与残（時間） = 付与残（時間） - 差分時間
        	        		    RemainingGrantTime = RemainingGrantTime - DifferenceTime;
//System.debug('after update 付与残(時間)1　'+RemainingGrantTime);

		    	                // 算出した付与残（時間）が８以上の場合、付与残（日数）+1して付与残（時間）-8する
        			            if(RemainingGrantTime >= 8){
                			            // 付与残（日数）=付与残（日数）+1
                        			    RemainingGrantDays =  RemainingGrantDays +1;
		                    	        // 付与残（時間）=付与残（時間）-8
        		                	    RemainingGrantTime = RemainingGrantTime - 8;
                		    	}

                                // 付与残（時間）がマイナスになった場合、付与残（日数）-1して付与残（時間）+8する
			    	            if(RemainingGrantTime < 0){
    	    			            // 付与残（日数）=付与残（日数）-1
        	    		            RemainingGrantDays = RemainingGrantDays -1;
            	   	    		    // 付与残（時間）=付与残（時間）+8
                	   	    		RemainingGrantTime = RemainingGrantTime + 8;
                   				}

		                	    // 付与消化（時間）の算出
        		            	// 付与消化（時間） = 付与消化（時間） + 差分時間
	                		    GrantDigestionTime = GrantDigestionTime + DifferenceTime;
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);

			                    // 算出した付与消化（時間）が８以上の場合、付与消化（日数）+1して付与消化（時間）-8する
        			            if(GrantDigestionTime >= 8){
            	    		            // 付与消化（日数）=付与消化（日数）+1
                	        		    GrantDigestionDays =  GrantDigestionDays +1;
		            	                // 付与消化（時間）=付与消化（時間）-8
        		        	            GrantDigestionTime = GrantDigestionTime - 8;
                		    	}

		                    	// 付与消化（時間）がマイナスになった場合、付与消化（日数）-1して付与消化（時間）+8する
			    	            if(GrantDigestionTime < 0){
        				            // 付与消化（日数）=付与消化（日数）-1
            			            GrantDigestionDays = GrantDigestionDays -1;
               		    		    // 付与消化（時間）=付与消化（時間）+8
                   		    		GrantDigestionTime = GrantDigestionTime + 8;
                   				}

                            }
                            // 付与残（日数）が(付与日数-1.0)より大きい場合　
                            // 繰越残（時間）から算出　
                            else{
                                // 付与残（時間）が残っている場合、差分時間を減算
                                if(RemainingGrantTime > 0){
	        		            	// 付与残（時間） = 付与残（時間） - 差分時間 
									RemainingGrantTime = RemainingGrantTime - DifferenceTime;
//System.debug('after update RemainingGrantTime　'+RemainingGrantTime);
//System.debug('after update GrantDigestionDays　'+GrantDigestionDays);

                                    //　付与消化（日数）が１より小さいの場合
                                    if(GrantDigestionDays < 1){
	                                    // 算出した付与残（時間） が８以上の場合、付与残（日数）+1して付与残（時間） -8する
    		    			            if(RemainingGrantTime >= 8){
        		        			        // 付与残（日数）=付与残（日数）+1
            		            			RemainingGrantDays =  RemainingGrantDays +1;
		        	                        // 差分時間 = 8 - 付与残（時間）
        		    		            	DifferenceTime = 8 - RemainingGrantTime;
	                    	                // 付与残（時間）=0
    	    			    	    	    RemainingGrantTime = 0;
			    	        		        // 付与消化（時間）=0
        				        		    GrantDigestionTime = 0;
                			    		}

	                                	// 繰越残（時間） = 繰越残（時間） - 差分時間
    	    	        		    	CarryForwardTime = CarryForwardTime - DifferenceTime;
//System.debug('after update 繰越残（時間）1　'+CarryForwardTime);

				    	                // 算出した繰越残（時間）が８以上の場合、繰越残（日数）+1して繰越残（時間）-8する
    	    				            if(CarryForwardTime >= 8){
        	    	    			            // 繰越残（日数）=繰越残（日数）+1
            	    	        			    CarryForwardDays =  CarryForwardDays +1;
		        	    	        	        // 繰越残（時間）=繰越残（時間）-8
        		    	    	        	    CarryForwardTime = CarryForwardTime - 8;
                			    		}

	                            	    // 繰越残（時間）がマイナスになった場合、繰越残（日数）-1して繰越残（時間）+8する
				    	            	if(CarryForwardTime < 0){
    		    			            	// 繰越残（日数）=繰越残（日数）-1
	        		    		            CarryForwardDays = CarryForwardDays -1;
    	        		   	    		    // 繰越残（時間）=繰越残（時間）+8
        	        		   	    		CarryForwardTime = CarryForwardTime + 8;
            	       					}

//System.debug('after update CarryOverDigestionTime　'+CarryOverDigestionTime);
//System.debug('after update DifferenceTime　'+DifferenceTime);
			        	        	    // 繰越消化（時間）の算出
    	    		    	        	// 繰越消化（時間） = 繰越消化（時間） + 差分時間
	    	            			    CarryOverDigestionTime = CarryOverDigestionTime + DifferenceTime;
//System.debug('after update 繰越消化（時間）1　'+CarryOverDigestionTime);

					                    // 算出した繰越消化（時間）が８以上の場合、繰越消化（日数）+1して繰越消化（時間）-8する
    		    			            if(CarryOverDigestionTime >= 8){
        		    	    		            // 繰越消化（日数）=繰越消化（日数）+1
            		    	        		    CarryOverDigestionDays =  CarryOverDigestionDays +1;
		        		    	                // 繰越消化（時間）=繰越消化（時間）-8
        		    		    	            CarryOverDigestionTime = CarryOverDigestionTime - 8;
                				    	}

			                    		// 繰越消化（時間）がマイナスになった場合、繰越消化（日数）-1して繰越消化（時間）+8する
				    	            	if(CarryOverDigestionTime < 0){
        					            	// 繰越消化（日数）=繰越消化（日数）-1
	        	    			            CarryOverDigestionDays = CarryOverDigestionDays -1;
    	        	   		    		    // 繰越消化（時間）=繰越消化（時間）+8
        	        	   		    		CarryOverDigestionTime = CarryOverDigestionTime + 8;
            	       					}

                                    }
                                    else{
                			            // 付与残（日数）=付与残（日数）+1
                        			    RemainingGrantDays =  RemainingGrantDays +1;
		                    	        // 付与残（時間）=付与残（時間）-8
        		                	    RemainingGrantTime = RemainingGrantTime - 8;

				                	    // 付与消化（時間）の算出
        				            	// 付与消化（時間） = 付与消化（時間） + 差分時間
	            		    		    GrantDigestionTime = GrantDigestionTime + DifferenceTime;
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);

			            		        // 算出した付与消化（時間）が８以上の場合、付与消化（日数）+1して付与消化（時間）-8する
        			            		if(GrantDigestionTime >= 8){
            	    		            		// 付与消化（日数）=付与消化（日数）+1
		                	        		    GrantDigestionDays =  GrantDigestionDays +1;
				            	                // 付与消化（時間）=付与消化（時間）-8
        				        	            GrantDigestionTime = GrantDigestionTime - 8;
                				    	}

		                    			// 付与消化（時間）がマイナスになった場合、付与消化（日数）-1して付与消化（時間）+8する
					    	            if(GrantDigestionTime < 0){
        						            // 付与消化（日数）=付与消化（日数）-1
            					            GrantDigestionDays = GrantDigestionDays -1;
               		    				    // 付与消化（時間）=付与消化（時間）+8
                   		    				GrantDigestionTime = GrantDigestionTime + 8;
                   						}

                                    }

//System.debug('after update 付与残(日数)1　'+RemainingGrantDays);
//System.debug('after update 付与残(時間)1　'+RemainingGrantTime);
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);
                                }
                                else{
//System.debug('after update 差分時間1　'+DifferenceTime);
                                
                                	// 繰越残（時間） = 繰越残（時間） - 差分時間
        	        		    	CarryForwardTime = CarryForwardTime - DifferenceTime;
//System.debug('after update 繰越残（時間）1　'+CarryForwardTime);

			    	                // 算出した繰越残（時間）が８以上の場合、繰越残（日数）+1して繰越残（時間）-8する
    	    			            if(CarryForwardTime >= 8){
        	        			            // 繰越残（日数）=繰越残（日数）+1
            	            			    CarryForwardDays =  CarryForwardDays +1;
		        	            	        // 繰越残（時間）=繰越残（時間）-8
        		    	            	    CarryForwardTime = CarryForwardTime - 8;
                			    	}

                            	    // 繰越残（時間）がマイナスになった場合、繰越残（日数）-1して繰越残（時間）+8する
			    	            	if(CarryForwardTime < 0){
    	    			            	// 繰越残（日数）=繰越残（日数）-1
	        	    		            CarryForwardDays = CarryForwardDays -1;
    	        	   	    		    // 繰越残（時間）=繰越残（時間）+8
        	        	   	    		CarryForwardTime = CarryForwardTime + 8;
            	       				}

		        	        	    // 繰越消化（時間）の算出
        		    	        	// 繰越消化（時間） = 繰越消化（時間） + 差分時間
	                			    CarryOverDigestionTime = CarryOverDigestionTime + DifferenceTime;
//System.debug('after update 繰越消化（時間）1　'+CarryOverDigestionTime);

				                    // 算出した繰越消化（時間）が８以上の場合、繰越消化（日数）+1して繰越消化（時間）-8する
    	    			            if(CarryOverDigestionTime >= 8){
        	    	    		            // 繰越消化（日数）=繰越消化（日数）+1
            	    	        		    CarryOverDigestionDays =  CarryOverDigestionDays +1;
		        	    	                // 繰越消化（時間）=繰越消化（時間）-8
        		    	    	            CarryOverDigestionTime = CarryOverDigestionTime - 8;
                			    	}

		                    		// 繰越消化（時間）がマイナスになった場合、繰越消化（日数）-1して繰越消化（時間）+8する
			    	            	if(CarryOverDigestionTime < 0){
        				            	// 繰越消化（日数）=繰越消化（日数）-1
	            			            CarryOverDigestionDays = CarryOverDigestionDays -1;
    	           		    		    // 繰越消化（時間）=繰越消化（時間）+8
        	           		    		CarryOverDigestionTime = CarryOverDigestionTime + 8;
            	       				}
                	            }
							}

                        }

                        // 有給休暇OBJ
	    		    	List<PaidHolidays__c> PaidHolidaysTMP = new List<PaidHolidays__c>();

	    	    	    // 有給休暇OBJを更新
    		            PaidHolidaysTMP.add(new PaidHolidays__c(
	        	            									Id = PaidHolidaysId,
																PaidLeaveRemainingDays__c = PaidLeaveRemainingDays,
																PaidLeaveRemainingTime__c = PaidLeaveRemainingTime,
																CarryForwardDays__c = CarryForwardDays,
																CarryForwardTime__c = CarryForwardTime,
																CarryOverDigestionDays__c = CarryOverDigestionDays,
																CarryOverDigestionTime__c = CarryOverDigestionTime,
																RemainingGrantDays__c = RemainingGrantDays,
																RemainingGrantTime__c = RemainingGrantTime,
																GrantDigestionDays__c = GrantDigestionDays,
																GrantDigestionTime__c = GrantDigestionTime,
																PaidRequest__c = '',
																DifferenceDays__c = NULL,
																DifferenceTime__c = NULL,
	            	        									TriggerUpdate__c = FALSE
	                	                       				)
		            	);
		                // 有給休暇OBJデータ更新
	    	            if (PaidHolidaysTMP.size() > 0) {
	        	            try{
System.debug('PaidHolidays__c　after update PaidHolidaysTMP　'+PaidHolidaysTMP);
	            	            update PaidHolidaysTMP;
	                	    }catch(DmlException e){
	                    	    System.debug('PaidHoliday__c after update1 有給休暇OBJの更新失敗');
	                        	Integer errNum = e.getNumDml();
		                        for(Integer i = 0; i < errNum; i++){
	    	                        PaidHolidaysTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
	        	                }
	            	        }
	                	}
                    }

	    	        // -----------------------------------------------------------------------------------
    	    	    // 有給休暇OBJの有休申請が”削除”の場合に処理する
            		// -----------------------------------------------------------------------------------
            		if(PaidHolidays.PaidRequest__c == '削除'){
System.debug('PaidHolidays__c　after update PaidHolidays.PaidRequest__c ==  削除　');
                
		                // ----------------------------------------------------------------------------------
        		        // 日申請（有休残日数が0以外）の場合
                		// ----------------------------------------------------------------------------------
		                if(DifferenceDays != 0){
System.debug('PaidHolidays__c　after update 日申請　');
        		            // 有休残日数の算出
                		    // 有休残日数 = 有休残日数 + 差分日数（加算）
		                    PaidLeaveRemainingDays = PaidLeaveRemainingDays + DifferenceDays;
//System.debug('after update 有休残日数1　'+PaidLeaveRemainingDays);

                            // 付与消化（日数）が差分日数(プラス値に変換)以上の場合
                            // 付与残（日数）に差分日数を加算、付与消化（日数）に差分日数を減算
                            if(GrantDigestionDays >= DifferenceDays){
	                            // 付与残（日数） = 付与残（日数） ; 差分日数
								RemainingGrantDays = RemainingGrantDays + DifferenceDays;

	                            // 算出した付与残（日数）が付与日数より大きい場合
	                            // 繰越残（日数）に差分日数を加算、繰越消化（日数）に差分日数を減算
	                            // 付与残（日数）に付与日数を設定、付与消化（日数）に０を設定
    	                        if(RemainingGrantDays > GrantDays){
        	                        // 差分日数を算出（付与残（日数）-付与日数）
            	                    DifferenceDays = RemainingGrantDays - GrantDays;

	                                // 繰越残（日数）に差分日数を加算
									CarryForwardDays = CarryForwardDays + DifferenceDays;
        	                        // 繰越消化（日数）から差分日数を減算
									CarryOverDigestionDays = CarryOverDigestionDays - DifferenceDays;

	            	                // 付与残（日数）=付与日数
                    	            RemainingGrantDays = GrantDays;
	                    	        // 付与消化（日数）=0
                            	    GrantDigestionDays = 0;
                            	}
	                            // 算出した付与残（日数）が付与日数以下の場合
	                            // 付与消化（日数）に差分日数を減算
	                            else{
    	                            // 付与消化（日数） = 付与消化（日数） + 差分日数
									GrantDigestionDays = GrantDigestionDays - DifferenceDays;
            	                }
                            }
                            // 付与消化（日数）が差分日数(プラス値に変換)より小さい場合
	                        // 繰越残（日数）に差分日数を加算、繰越消化（日数）に差分日数を減算
                            else{
                                // 付与消化（日数）が0以外は付与消化（日数）から減算
                                if(GrantDigestionDays > 0){
        	                        // 差分日数を算出（差分日数-付与消化（日数））
            	                    DifferenceDays = DifferenceDays - GrantDigestionDays;
                                    
	            	                // 付与残（日数）=付与残（日数）+付与消化（日数）
                    	            RemainingGrantDays = RemainingGrantDays + GrantDigestionDays;
                                    // 付与消化（日数）に0を設定
                                    GrantDigestionDays = 0;
                                }
                                
	                            // 繰越残（日数）に差分日数を加算
								CarryForwardDays = CarryForwardDays + DifferenceDays;
        	                    // 繰越消化（日数）から差分日数を減算
								CarryOverDigestionDays = CarryOverDigestionDays - DifferenceDays;

                                // 繰越残（日数）が1以上かつ付与残（時間）が１以上の場合
                                // 繰越残（日数）-1
                                // 繰越残（時間）=付与残（時間）、繰越消化（時間）=付与消化（時間）
                                // 付与残（日数）+1、付与残（時間）=0、付与消化（時間）=0
                                iF(CarryForwardDays >= 1 && RemainingGrantTime >= 1){
	                                // 繰越残（日数）-1
	                                CarryForwardDays = CarryForwardDays -1;
	                                // 繰越残（時間）=付与残（時間）
	                                CarryForwardTime = RemainingGrantTime;
	                                // 繰越消化（時間）=付与消化（時間）
	                                CarryOverDigestionTime = GrantDigestionTime;
	                                // 付与残（日数）+1
	                                RemainingGrantDays = RemainingGrantDays +1;
	                                // 付与残（時間）=0
	                                RemainingGrantTime = 0;
	                                // 付与消化（時間）=0
	                                GrantDigestionTime = 0;
                                    
                            	}
                            
                        	}
//System.debug('after update 繰越残(日数)1　'+CarryForwardDays);
//System.debug('after update 繰越消化(日数)1　'+CarryOverDigestionDays);
//System.debug('after update 付与残(日数)1　'+RemainingGrantDays);
//System.debug('after update 付与消化(日数)1　'+GrantDigestionDays);
                        }

                        // ----------------------------------------------------------------------------------
        		        // 時間申請（差分時間が0以外）の場合
                		// ----------------------------------------------------------------------------------
                        if(DifferenceTime != 0){
System.debug('PaidHolidays__c　after update 時間申請　');
		                    // 有休残時間の算出
        		            // 有休残時間 = 有休残時間 + 差分時間
                		    PaidLeaveRemainingTime = PaidLeaveRemainingTime + DifferenceTime;
//System.debug('after update 有休残時間1　'+PaidLeaveRemainingTime);

		                    // 算出した有休残時間が８以上の場合、有休残日数+1して有休残時間-8する
        		            if(PaidLeaveRemainingTime >= 8){
                		            // 有休残日数=有休残日数+1
                        		    PaidLeaveRemainingDays =  PaidLeaveRemainingDays +1;
		                            // 有休残時間=有休残時間-8
        		                    PaidLeaveRemainingTime = PaidLeaveRemainingTime - 8;
                		    }
                        
	                    	// 有休残時間がマイナスになった場合、有休残日数-1して有休残時間+8する
		    	            if(PaidLeaveRemainingTime < 0){
        			            // 有休残日数=有休残日数-1
            		            PaidLeaveRemainingDays = PaidLeaveRemainingDays -1;
               	    		    // 有休残時間=有休残時間+8
                   	    		PaidLeaveRemainingTime = PaidLeaveRemainingTime + 8;
                   			}

//System.debug('after update RemainingGrantDays　'+RemainingGrantDays);
//System.debug('after update RemainingGrantTime　'+RemainingGrantTime);
//System.debug('after update DifferenceTime　'+DifferenceTime);
                            // 付与残（日数）が(付与日数-1.0)以下かつ算出した付与残(時間)が8より小さい場合
                            // 付与残（時間）から算出
                            if(RemainingGrantDays <= GrantDays-1.0 && 8 > (RemainingGrantTime+DifferenceTime)){

                                // 付与残（時間） = 付与残（時間） + 差分時間
        	        		    RemainingGrantTime = RemainingGrantTime + DifferenceTime;
//System.debug('after update 付与残(時間)1　'+RemainingGrantTime);

		    	                // 算出した付与残（時間）が８以上の場合、付与残（日数）+1して付与残（時間）-8する
        			            if(RemainingGrantTime >= 8){
                			            // 付与残（日数）=付与残（日数）+1
                        			    RemainingGrantDays =  RemainingGrantDays +1;
		                    	        // 付与残（時間）=付与残（時間）-8
        		                	    RemainingGrantTime = RemainingGrantTime - 8;
                		    	}

                                // 付与残（時間）がマイナスになった場合、付与残（日数）-1して付与残（時間）+8する
			    	            if(RemainingGrantTime < 0){
    	    			            // 付与残（日数）=付与残（日数）-1
        	    		            RemainingGrantDays = RemainingGrantDays -1;
            	   	    		    // 付与残（時間）=付与残（時間）+8
                	   	    		RemainingGrantTime = RemainingGrantTime + 8;
                   				}

		                	    // 付与消化（時間）の算出
        		            	// 付与消化（時間） = 付与消化（時間） - 差分時間
	                		    GrantDigestionTime = GrantDigestionTime - DifferenceTime;
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);

			                    // 算出した付与消化（時間）が８以上の場合、付与消化（日数）+1して付与消化（時間）-8する
        			            if(GrantDigestionTime >= 8){
            	    		            // 付与消化（日数）=付与消化（日数）+1
                	        		    GrantDigestionDays =  GrantDigestionDays +1;
		            	                // 付与消化（時間）=付与消化（時間）-8
        		        	            GrantDigestionTime = GrantDigestionTime - 8;
                		    	}

		                    	// 付与消化（時間）がマイナスになった場合、付与消化（日数）-1して付与消化（時間）+8する
			    	            if(GrantDigestionTime < 0){
        				            // 付与消化（日数）=付与消化（日数）-1
            			            GrantDigestionDays = GrantDigestionDays -1;
               		    		    // 付与消化（時間）=付与消化（時間）+8
                   		    		GrantDigestionTime = GrantDigestionTime + 8;
                   				}

                            }

                            // 付与残（日数）が(付与日数-1.0)より大きい場合　
                            // 繰越残（時間）から算出　
                            else{
                                // 付与残（時間）が残っている場合、差分時間を減算
                                if(RemainingGrantTime > 0){
	        		            	// 付与残（時間） = 付与残（時間） + 差分時間 
									RemainingGrantTime = RemainingGrantTime + DifferenceTime;

                                    //　付与消化（日数）が１より小さいの場合
                                    if(GrantDigestionDays < 1){
	                                    // 算出した付与残（時間） が８以上の場合、付与残（日数）+1して付与残（時間） -8する
    		    			            if(RemainingGrantTime >= 8){
        		        			        // 付与残（日数）=付与残（日数）+1
            		            			RemainingGrantDays =  RemainingGrantDays +1;
		        	                        // 差分時間 = 8 - 付与残（時間）
        		    		            	DifferenceTime = 8 - RemainingGrantTime;
	                    	                // 付与残（時間）=0
    	    			    	    	    RemainingGrantTime = 0;
			    	        		        // 付与消化（時間）=0
        				        		    GrantDigestionTime = 0;
                			    		}

	                                	// 繰越残（時間） = 繰越残（時間） - 差分時間
    	    	        		    	CarryForwardTime = CarryForwardTime - DifferenceTime;
//System.debug('after update 繰越残（時間）1　'+CarryForwardTime);

				    	                // 算出した繰越残（時間）が８以上の場合、繰越残（日数）+1して繰越残（時間）-8する
    	    				            if(CarryForwardTime >= 8){
        	    	    			            // 繰越残（日数）=繰越残（日数）+1
            	    	        			    CarryForwardDays =  CarryForwardDays +1;
		        	    	        	        // 繰越残（時間）=繰越残（時間）-8
        		    	    	        	    CarryForwardTime = CarryForwardTime - 8;
                			    		}

	                            	    // 繰越残（時間）がマイナスになった場合、繰越残（日数）-1して繰越残（時間）+8する
				    	            	if(CarryForwardTime < 0){
    		    			            	// 繰越残（日数）=繰越残（日数）-1
	        		    		            CarryForwardDays = CarryForwardDays -1;
    	        		   	    		    // 繰越残（時間）=繰越残（時間）+8
        	        		   	    		CarryForwardTime = CarryForwardTime + 8;
            	       					}

			        	        	    // 繰越消化（時間）の算出
    	    		    	        	// 繰越消化（時間） = 繰越消化（時間） - 差分時間
	    	            			    CarryOverDigestionTime = CarryOverDigestionTime + DifferenceTime;
//System.debug('after update 繰越消化（時間）1　'+CarryOverDigestionTime);

					                    // 算出した繰越消化（時間）が８以上の場合、繰越消化（日数）+1して繰越消化（時間）-8する
    		    			            if(CarryOverDigestionTime >= 8){
        		    	    		            // 繰越消化（日数）=繰越消化（日数）+1
            		    	        		    CarryOverDigestionDays =  CarryOverDigestionDays +1;
		        		    	                // 繰越消化（時間）=繰越消化（時間）-8
        		    		    	            CarryOverDigestionTime = CarryOverDigestionTime - 8;
                				    	}

			                    		// 繰越消化（時間）がマイナスになった場合、繰越消化（日数）-1して繰越消化（時間）+8する
				    	            	if(CarryOverDigestionTime < 0){
        					            	// 繰越消化（日数）=繰越消化（日数）-1
	        	    			            CarryOverDigestionDays = CarryOverDigestionDays -1;
    	        	   		    		    // 繰越消化（時間）=繰越消化（時間）+8
        	        	   		    		CarryOverDigestionTime = CarryOverDigestionTime + 8;
            	       					}

                                    }
                                    else{
                			            // 付与残（日数）=付与残（日数）+1
                        			    RemainingGrantDays =  RemainingGrantDays +1;
		                    	        // 付与残（時間）=付与残（時間）-8
        		                	    RemainingGrantTime = RemainingGrantTime - 8;

				                	    // 付与消化（時間）の算出
        				            	// 付与消化（時間） = 付与消化（時間） - 差分時間
	            		    		    GrantDigestionTime = GrantDigestionTime - DifferenceTime;
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);

			            		        // 算出した付与消化（時間）が８以上の場合、付与消化（日数）+1して付与消化（時間）-8する
        			            		if(GrantDigestionTime >= 8){
            	    		            		// 付与消化（日数）=付与消化（日数）+1
		                	        		    GrantDigestionDays =  GrantDigestionDays +1;
				            	                // 付与消化（時間）=付与消化（時間）-8
        				        	            GrantDigestionTime = GrantDigestionTime - 8;
                				    	}

		                    			// 付与消化（時間）がマイナスになった場合、付与消化（日数）-1して付与消化（時間）+8する
					    	            if(GrantDigestionTime < 0){
        						            // 付与消化（日数）=付与消化（日数）-1
            					            GrantDigestionDays = GrantDigestionDays -1;
               		    				    // 付与消化（時間）=付与消化（時間）+8
                   		    				GrantDigestionTime = GrantDigestionTime + 8;
                   						}

                                    }

//System.debug('after update 付与残(日数)1　'+RemainingGrantDays);
//System.debug('after update 付与残(時間)1　'+RemainingGrantTime);
//System.debug('after update 付与消化(時間)1　'+GrantDigestionTime);
                                }
                                else{
//System.debug('after update 差分時間1　'+DifferenceTime);
                                
                                	// 繰越残（時間） = 繰越残（時間） + 差分時間
        	        		    	CarryForwardTime = CarryForwardTime + DifferenceTime;
//System.debug('after update 繰越残（時間）1　'+CarryForwardTime);

			    	                // 算出した繰越残（時間）が８以上の場合、繰越残（日数）+1して繰越残（時間）-8する
    	    			            if(CarryForwardTime >= 8){
        	        			            // 繰越残（日数）=繰越残（日数）+1
            	            			    CarryForwardDays =  CarryForwardDays +1;
		        	            	        // 繰越残（時間）=繰越残（時間）-8
        		    	            	    CarryForwardTime = CarryForwardTime - 8;
                			    	}

                            	    // 繰越残（時間）がマイナスになった場合、繰越残（日数）-1して繰越残（時間）+8する
			    	            	if(CarryForwardTime < 0){
    	    			            	// 繰越残（日数）=繰越残（日数）-1
	        	    		            CarryForwardDays = CarryForwardDays -1;
    	        	   	    		    // 繰越残（時間）=繰越残（時間）+8
        	        	   	    		CarryForwardTime = CarryForwardTime + 8;
            	       				}

		        	        	    // 繰越消化（時間）の算出
        		    	        	// 繰越消化（時間） = 繰越消化（時間） - 差分時間
	                			    CarryOverDigestionTime = CarryOverDigestionTime - DifferenceTime;
//System.debug('after update 繰越消化（時間）1　'+CarryOverDigestionTime);

				                    // 算出した繰越消化（時間）が８以上の場合、繰越消化（日数）+1して繰越消化（時間）-8する
    	    			            if(CarryOverDigestionTime >= 8){
        	    	    		            // 繰越消化（日数）=繰越消化（日数）+1
            	    	        		    CarryOverDigestionDays =  CarryOverDigestionDays +1;
		        	    	                // 繰越消化（時間）=繰越消化（時間）-8
        		    	    	            CarryOverDigestionTime = CarryOverDigestionTime - 8;
                			    	}

		                    		// 繰越消化（時間）がマイナスになった場合、繰越消化（日数）-1して繰越消化（時間）+8する
			    	            	if(CarryOverDigestionTime < 0){
        				            	// 繰越消化（日数）=繰越消化（日数）-1
	            			            CarryOverDigestionDays = CarryOverDigestionDays -1;
    	           		    		    // 繰越消化（時間）=繰越消化（時間）+8
        	           		    		CarryOverDigestionTime = CarryOverDigestionTime + 8;
            	       				}
                	            }
                            }

                        }

                	    // 有給休暇OBJ
	    		    	List<PaidHolidays__c> PaidHolidaysTMP = new List<PaidHolidays__c>();

	    	    	    // 有給休暇OBJを更新
    		            PaidHolidaysTMP.add(new PaidHolidays__c(
	        	            									Id = PaidHolidaysId,
																PaidLeaveRemainingDays__c = PaidLeaveRemainingDays,
																PaidLeaveRemainingTime__c = PaidLeaveRemainingTime,
																CarryForwardDays__c = CarryForwardDays,
																CarryForwardTime__c = CarryForwardTime,
																CarryOverDigestionDays__c = CarryOverDigestionDays,
																CarryOverDigestionTime__c = CarryOverDigestionTime,
																RemainingGrantDays__c = RemainingGrantDays,
																RemainingGrantTime__c = RemainingGrantTime,
																GrantDigestionDays__c = GrantDigestionDays,
																GrantDigestionTime__c = GrantDigestionTime,
																PaidRequest__c = '',
																DifferenceDays__c = NULL,
																DifferenceTime__c = NULL,
	            	        									TriggerUpdate__c = FALSE
	                	                       				)
		            	);
		                // 有給休暇OBJデータ更新
	    	            if (PaidHolidaysTMP.size() > 0) {
	        	            try{
System.debug('PaidHolidays__c　after update PaidHolidaysTMP　'+PaidHolidaysTMP);
	            	            update PaidHolidaysTMP;
	                	    }catch(DmlException e){
	                    	    System.debug('PaidHoliday__c after update1 有給休暇OBJの更新失敗');
	                        	Integer errNum = e.getNumDml();
		                        for(Integer i = 0; i < errNum; i++){
	    	                        PaidHolidaysTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
	        	                }
	            	        }
	                	}

                    }

                }else{
	                if(PaidHolidays.DataLock__c == True){
			            // エラーメッセージ表示
    			        for(PaidHolidays__c opp: Trigger.new ) {
							opp.addError('データロックされているため更新できません！');
           			    }
                	}
                	else{
                		// エラーメッセージ表示
                		for(PaidHolidays__c opp: Trigger.new ) {
                			opp.addError('変更はできません！　削除して再度新規登録してください！');
                		}
                    }
            	}
            }
        }

        // after delete処理
        //if (Trigger.isAfter && Trigger.isDelete) {
//System.debug('PaidHolidays__c　after delete処理　');
        //}

        // after undelete処理
        //if (Trigger.isAfter && Trigger.isUnDelete ){
//System.debug('PaidHolidays__c　after undelete処理　');
        //}

        // before insert処理
        //if(Trigger.isBefore && Trigger.isInsert){
//System.debug('PaidHolidays__c　before insert処理　');
        //}

        // before update処理
        //if (Trigger.isBefore && Trigger.isUpdate) {
//System.debug('PaidHolidays__c　before update処理　');
        //}

        // before delete処理
        if (Trigger.isBefore && Trigger.isDelete) {
System.debug('PaidHolidays__c　before delete処理　');
            // ----------------------------------------------------------------------
            // 変更前の有給休暇レコード取得
            // ----------------------------------------------------------------------
            List<PaidHolidays__c> PaidHolidaysListOLD = Trigger.old;
            PaidHolidays__c PaidHolidaysOLD = PaidHolidaysListOLD.get(0);
            // 関連メンバーを設定
            ID MasterMemberId = PaidHolidaysOLD.MasterMemberId__c;
            // 付与回数を設定
//            Decimal PaidGrantNumberOLD = PaidHolidaysOLD.PaidGrantNumber__c;
	        // 有休付与（日数）を設定
//            Decimal PaidGrantDaysOLD = PaidHolidaysOLD.PaidGrantDays__c;

            // ------------------------------------------------------------------------------------------------------------
            // 繰越消化（日数）または繰越消化（時間）に値が入っている場合はエラー（削除できない）
            // 付与消化（日数）または付与消化（時間）に値が入っている場合はエラー（削除できない）
            // データロックがTRUEの場合はエラー（削除できない）
            // ------------------------------------------------------------------------------------------------------------
            if((PaidHolidaysOLD.CarryOverDigestionDays__c != 0 || 
				PaidHolidaysOLD.CarryOverDigestionTime__c != 0 || 
				PaidHolidaysOLD.GrantDigestionDays__c != 0 || 
				PaidHolidaysOLD.GrantDigestionTime__c != 0 || 
				PaidHolidaysOLD.DataLock__c == True)){

                if(PaidHolidaysOLD.DataLock__c == True){
		            // エラーメッセージ表示
    		        for(PaidHolidays__c opp: Trigger.old ) {
						opp.addError('データロックされているため削除できません！');
           		    }
                }
                else{
		            // エラーメッセージ表示
    		        for(PaidHolidays__c opp: Trigger.old ) {
						opp.addError('有休取得されているため削除できません！');
           		    }
                }
            }
        }

    }
}