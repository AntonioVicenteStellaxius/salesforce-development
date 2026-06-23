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
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after update, after insert, after delete, after undelete) {
    new OpportunityTriggerHandler().run();
}