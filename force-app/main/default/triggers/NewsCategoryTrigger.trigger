/**
 * Trigger for News_Category__c object to sync news from API when Sync__c field is true
 */
trigger NewsCategoryTrigger on News_Category__c (after insert, after update) {
    // - Call appropriate handler methods for insert and update contexts
    switch on Trigger.operationType{
        when AFTER_INSERT{
            List<News_Category__c> newNewsCategories = (List<News_Category__c>) Trigger.new;
            NewsCategoryTriggerHandler.handleInsert(newNewsCategories);
        }
        when AFTER_UPDATE{
            List<News_Category__c> newNewsCategories = (List<News_Category__c>) Trigger.new;
            Map<Id, News_Category__c> oldNewsCategories = (Map<Id, News_Category__c>) Trigger.oldMap;
            NewsCategoryTriggerHandler.handleUpdate(newNewsCategories, oldNewsCategories);
        }
    }
}