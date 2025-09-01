/**
 * Handler class for NewsCategoryTrigger
 */
public with sharing class NewsCategoryTriggerHandler {
    
    /**
     * Handles after insert events for News_Category__c
     * Uses Queueable for callouts when Sync__c is true
     * @param newRecords List of newly inserted News_Category__c records
     */
    private static Boolean insertHasRun = false;
    private static Boolean updateHasRun = false;
    
    public static void handleInsert(List<News_Category__c> newRecords) {
        
        // - Filter categories that need to be synced (Sync__c = true)
        // - Call queueable method for callouts
        if(!insertHasRun){
            List<News_Category__c> categoriesToProcess = new List<News_Category__c>();
            for(News_Category__c newsCategory: newRecords){
                if(newsCategory.Sync__c){
                    categoriesToProcess.add(newsCategory);
                }
            }
        syncCategoriesWithQueueable(categoriesToProcess);}
        insertHasRun = true;
    }
    
    /**
     * Handles after update events for News_Category__c
     * Uses Queueable Apex for callouts when Sync__c is true
     * @param newRecords List of updated News_Category__c records
     * @param oldMap Map of old record states
     */
    public static void handleUpdate(List<News_Category__c> newRecords, Map<Id, News_Category__c> oldMap) {
        // - Filter categories that need to be synced (Sync__c changed from false to true)
        // - Call queueable method for callouts
        if(!updateHasRun){
            List<News_Category__c> categoriesToProcess = new List<News_Category__c>();
            for(News_Category__c newCategory: newRecords){
                News_Category__c oldCategory = oldMap.get(newCategory.Id);
                if(newCategory.Sync__c && (oldCategory.Sync__c != newCategory.Sync__c)){
                    categoriesToProcess.add(newCategory);
                }
            }
            syncCategoriesWithQueueable(categoriesToProcess);
            updateHasRun = true;
        }
    }
    
    /**
     * Queueable method to sync categories using the NewsAPI
     * @param categoriesToSync List of News_Category__c records to sync
     */
    private static void syncCategoriesWithQueueable(List<News_Category__c> categoriesToSync) {
        for(News_Category__c category: categoriesToSync){
            System.enqueueJob(new NewsCategoryQueueable(category, 0,0));
        }
        
    }
}