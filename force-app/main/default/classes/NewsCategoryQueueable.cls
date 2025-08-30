/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    // Static variable for maximum pages to fetch
    private static final Integer MAX_PAGES = 20;
    private News_Category__c category;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param category The News_Category__c record
     * @param currentPage Current page to process
     */
    public NewsCategoryQueueable(News_Category__c category, Integer currentPage) {
        this.category = category;
        this.currentPage = currentPage;
        System.debug('** Category: ' + this.category.name);
        System.debug('** Page: ' + this.currentPage);
    }
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
        // IMPORTANT: Create a separate instance of the category for updates
        News_Category__c updatedCategory  = new News_Category__c(Id = this.category.Id, Name = this.category.Name, Sync__c = this.category.Sync__c, Last_Synced__c = this.category.Last_Synced__c);
        
        String categoryName = updatedCategory?.Name.toLowerCase();
        if(String.isBlank(categoryName)){
            throw new NewsApiService.NewsAPIProcessingException('** Category name is null');
        }
        try {
            // - Call NewsAPI for the current page
            // - Convert API articles to Salesforce articles using NewsAPIResponse.convertToSObject
            // - Add category reference to each article
            // - Insert the articles
            // - Check if reached MAX_PAGES or no more articles
            // HINT: When requeuing the job check if tests are running
            // - Update category with last synced date and sync flag = false
            System.debug('** Processing callout for ' + categoryName + ' at page ' + this.currentPage);
            NewsApiResponse newsApiResp = NewsApiService.getTopHeadlinesByCategory(categoryName, this.currentPage);
            if(newsApiResp == null){
                throw new NewsApiService.NewsAPIProcessingException('** No newsApiResponse created in queueable');
            }
            List<Article__c> articleRecords = new List<Article__c>();
            for(NewsAPIResponse.Article art: newsApiResp.articles){
                Article__c articleRec = NewsAPIResponse.convertToSObject(art);
                articleRec = NewsAPIResponse.addCategoryToArticleRecord(articleRec, updatedCategory);
                articleRecords.add(articleRec);
            }
            insert articleRecords;
            
            if(!Test.isRunningTest() && (this.currentPage < MAX_PAGES) && !newsApiResp.articles.isEmpty()){
                System.enqueueJob(new NewsCategoryQueueable(updatedCategory, this.currentPage + 1));
            } else
            {
                updatedCategory.Sync__c = FALSE;
                updatedCategory.Last_Synced__c = Datetime.NOW();
                update updatedCategory;
            }
        }
        
        catch (Exception e) {
            Error errorInfo = new Error(e);
            errorInfo.logError();
            throw new NewsApiService.NewsAPIProcessingException('** Error executing NewsCategoryQueueable ' + e.getMessage());
        }
    }
}