/**
 * @description       : 
 * @author            : António Vicente
 * @group             : 
 * @last modified on  : 2026-06-23
 * @last modified by  : António Vicente
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   2026-06-23   António Vicente   Initial Version
**/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> triggerNew;
    private List<Opportunity> triggerOld;
    private Map<Id, Opportunity> triggerMapNew;
    private Map<Id, Opportunity> triggerMapOld;
    private static final String CLASS_NAME = 'OpportunityTriggerHandler';

    /**
     * @description Constructor that sets class variables based on Trigger
     * context vars
     */
    public OpportunityTriggerHandler() {
        this.triggerOld = (List<Opportunity>) Trigger.old;
        this.triggerNew = (List<Opportunity>) Trigger.new;
        this.triggerMapNew = (Map<Id, Opportunity>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void afterInsert() {
        calculateAccountTotalClosedWonValue();
    }

    public override void afterUpdate() {
        calculateAccountTotalClosedWonValue();
    }

    public override void afterDelete() {
        calculateAccountTotalClosedWonValue();
    }

    public override void afterUndelete() {
        calculateAccountTotalClosedWonValue();
    }

    /**
    * @description Calculate Opportunity Account Total Closed Won Value
    * @author António Vicente | 2026-06-23 
    **/
    private void calculateAccountTotalClosedWonValue () {
        final String METHOD_NAME = 'calculateAccountTotalClosedWonValue';

        System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | Started.');

        try {
            Map<Id, Decimal> accountsMap = new Map<Id, Decimal>();
            List<Account> accountList = new List<Account>();

            for (Opportunity opp : triggerNew) {
                if (opp.IsWon && opp.IsClosed) {
                    if (accountsMap.containsKey(opp.AccountId)) {
                        Decimal currentAmount = accountsMap.get(opp.AccountId) + opp.Amount;

                        accountsMap.put(opp.AccountId, currentAmount);
                        continue;
                    }

                    accountsMap.put(opp.AccountId, opp.Amount);
                }

                continue;
            }

            if (accountsMap.isEmpty()) {
                System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | ' + 'No Opportunities were Closed and Won.');
                return;
            }

            System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | ' + ': ' + accountsMap);

            for (Account acc : [SELECT Id, Total_Closed_Won_Value__c FROM Account WHERE Id IN :accountsMap.keySet()]) {
                Account newAcc = new Account(
                    Id = acc.Id,
                    Total_Closed_Won_Value__c = accountsMap.get(acc.Id)
                );

                accountList.add(newAcc);
            }

            Database.update(accountList, false);
        }
        catch (Exception ex) {
            System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | ' + ex.getMessage());
            System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | ' + ex.getLineNumber());
        }

        System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' | Finished.');
    }
}