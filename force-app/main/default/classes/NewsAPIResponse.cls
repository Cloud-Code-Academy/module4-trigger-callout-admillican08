/**
 * Wrapper class for parsing the NewsAPI response
 */
public class NewsAPIResponse {
    public String status { get; set; }
    public Integer totalResults { get; set; }
    public List<Article> articles { get; set; }
    
    /**
     * Inner class representing a news article
     */
    public class Article {
        public Source source {get; set;}
        public String sourceStr {get; set;}
        public String author {get; set;}
        public String title { get; set; }
        public String description {get; set;}
        public String url { get; set; }
        public String urlToImage { get; set; }
        public String publishedAt {get; set;}
        public Datetime publishedAtDatetime {get; set;}
        public String content {get; set;}
        public final String country = 'us';
        public String name {get; set;}
        
        public Article(Article art){
            this.source = new Source(art.source);
            this.sourceStr = source?.sourceStr ?? 'not provided';
            this.author = art?.author ?? 'not provided';
            this.title = art?.title ?? 'not provided';
            this.description = art?.description ?? 'not provided';
            this.url = art?.url;
            this.urlToImage = art?.urlToImage ?? 'not provided';
            this.publishedAt = art?.publishedAt;
            this.publishedAtDatetime = this.convertStringToDate(this.publishedAt);
            this.content = art?.content;
            this.name = this.createArticleName();
            System.debug('** Article name: ' + this.name);
        }
        
        public Article(){
        }
        
        private Datetime convertStringToDate(String publishedAt){
            if(String.isNotBlank(publishedAt)){
                try{
                    publishedAt = publishedAt.replace('T', ' ');
                    publishedAt = publishedAt.replace('Z', '');
                    return Datetime.valueOf(publishedAt);
                }
                catch(Exception ex){
                    Logger.debug('Error converting date in NewsAPIResponse.convertStringToDate(): ' + ex.getMessage());
                    Logger.saveLog();
                    System.debug('** Stack trace: ' + ex.getStackTraceString());
                    throw new NewsAPIService.NewsAPIProcessingException('** Error converting date from string: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
                }
            }
            else {
                return System.now();
            }
        }
        
        private String createArticleName(){
            List<String> titleArr = this?.title.split(' ');
            List<String> dateArr = this.publishedAt?.split('T');
            String titlePart = '';
            if(!titleArr.isEmpty()){
                for(Integer i=0; i<(titleArr.size()-1); i++){
                    titlePart += titleArr[i] + '_';
                }
                titlePart = titlePart += titleArr[titleArr.size()-1];
                
                titlePart = titlePart.replaceAll('\\W','');
                return dateArr[0] + '-' + titlePart.left(69);
            }
            else{
                return 'ErrorInGettingName' + '-000000';
            }
        }
    }
    
    /**
     * Inner class representing a news source
     */
    public class Source {
        public String id { get; set; }
        public String name { get; set; }
        public String sourceStr {get; set;}
        
        
        public Source(Source src){
            this.id = src.id;
            this.name = src.name;
            this.sourceStr = this.convertSourceToString();
        }
        
        @TestVisible
        private String convertSourceToString(){
            if(String.isBlank(this.id) || (this.id.replaceAll('-',' ').equalsIgnoreCase(this.name))){
                return this.name.left(255);
            }
            else return (this.id + '-' + this.name).left(255);
        }
    }
    
    /**
     * Static method to convert an API article to a Salesforce Article__c record
     * @param apiArticle The API article to convert
     * @return Article__c The Salesforce record
     */
    public static Article__c convertToSObject(Article apiArticle) {
        
        // Consider:
        // - Generating a unique record name
        // - Setting article fields from the API response
        // - Handling content length limits if needed
        // - Handling date conversion
        Article__c newArticleRecord = new Article__c(
            Name = apiArticle.name,
        Author__c = apiArticle.author.left(255),
        Content__c = apiArticle.content,
        Country__c = apiArticle?.COUNTRY ?? 'US',
        Description__c = apiArticle.description,
        Published_At__c = apiArticle.publishedAtDatetime,
        Source__c = apiArticle.sourceStr.left(255),
        Title__c = apiArticle.title.left(255),
        url__c = apiArticle.url.left(255),
        urlToImage__c = apiArticle.urlToImage.left(255));
        
        return newArticleRecord;
    }
    
    public static Article__c addCategoryToArticleRecord(Article__c article, News_Category__c category){
        article.Category__c = category.Name;
        article.News_Category__c = category.Id;
        return article;
    }
    
}