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
            this.sourceStr = source.sourceStr;
            this.title = art.title;
            this.description = art.description;
            this.url = art.url;
            this.urlToImage = art.urlToImage;
            this.publishedAt = art.publishedAt;
            this.publishedAtDatetime = this.convertStringToDate(this.publishedAt);
            this.name = this.createArticleName();
        }
        
        public Article(){
        }
        
        private Datetime convertStringToDate(String publishedAt){
            try{
                publishedAt = publishedAt.replace('T', ' ');
                publishedAt = publishedAt.replace('Z', '');
                return Datetime.valueOf(publishedAt);
            }
            catch(Exception ex){
                Error errorInfo = new Error(ex);
                errorInfo.logError();
                throw new NewsAPIService.NewsAPIProcessingException('** Error converting date from string: ' + ex.getMessage());
            }
        }
        
        private String createArticleName(){
            String randomNumStr = String.valueOf(Integer.valueof((Math.random() * 100)));
            List<String> titleArr = this?.title.split(' ');
            String pubdAt = this?.publishedAt.replace('Z', '');
            List<String> dateArr = pubdAt?.split('T');
            if(!titleArr.isEmpty()){
                String titlePart = titleArr[0]+ '_' + titleArr[1] + '_' + titleArr[2];
                titlePart = titlePart.replaceAll('\\W','');
                return dateArr[0] +  '-' + dateArr[1] + titlePart.left(69) + randomNumStr;
            }
            else{
                return 'ErrorInGettingName' + randomNumStr;
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
                return this.name;
            }
            else return this.id + '-' + this.name;
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
        Author__c = apiArticle.author,
        Content__c = apiArticle.content,
        Country__c = apiArticle.COUNTRY,
        Description__c = apiArticle.description,
        Published_At__c = apiArticle.publishedAtDatetime,
        Source__c = apiArticle.sourceStr,
        Title__c = apiArticle.title,
        url__c = apiArticle.url,
        urlToImage__c = apiArticle.urlToImage);
        
        return newArticleRecord;
    }
    
    public static Article__c addCategoryToArticleRecord(Article__c article, News_Category__c category){
        article.Category__c = category.Name;
        article.News_Category__c = category.Id;
        return article;
    }
    
}