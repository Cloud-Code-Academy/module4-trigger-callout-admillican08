/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
    private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI'; //https://newsapi.org
    private static final String API_ENDPOINT = '/v2/top-headlines?country=us&category=';
    private static final Integer PAGE_SIZE = 20;
    public static List<String> categoryList {get; private set;}
    
    
    /**
     * Fetches top headlines for a specified category with pagination support
     * @param category The news category (business, entertainment, general, health, science, sports, technology)
     * @param page Page number for pagination
     * @return NewsAPIResponse The wrapper object containing the API response
     */
    public static NewsAPIResponse getTopHeadlinesByCategory(String category, Integer page) {
        // - Validate parameters
        // - Build the request URL with fixed page size
        // - Make the callout
        // - Parse and return the response
        categoryList = createCategoryList();
        if(!categoryList.contains(category) || category == null){
            System.debug('** Category: ' + category);
            throw new NewsApiProcessingException('Invalid category supplied');
        }
        if(page > PAGE_SIZE){
            throw new NewsApiProcessingException('Page exceeds maximum number of pages');
        }
        String endpoint = API_NAMED_CREDENTIAL + API_ENDPOINT + category + '&page=' + page;
        NewsAPIResponse newsApiResp;
        try{
            String jsonResponse = makeCallout(endpoint).getBody();
            newsApiResp = parseResponse(jsonResponse);
            
        } catch(Exception ex){
            Error errorInfo = new Error(ex);
            errorInfo.logError();
        }
        return newsApiResp;
    }
    
    /**
     * Helper method to make the HTTP callout
     * @param endpoint The full URL with parameters
     * @return HttpResponse The HTTP response
     */
    private static HttpResponse makeCallout(String endpoint) {
        // - Create and configure HTTP request
        // - Make the callout
        // - Handle exceptions
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse resp = http.send(request);
        ApiResponse apiResponse = new ApiResponse(resp);
        if(apiResponse.isSuccess){
            return resp;
        } else {
            throw new NewsAPIProcessingException('** Error parsing News Api Response: ' + apiResponse.responseMsg);
        }
    }
    
    
    /**
     * Helper method to parse the JSON response
     * @param jsonResponse The JSON response string
     * @return NewsAPIResponse The parsed response object
     */
    private static NewsAPIResponse parseResponse(String jsonResponse) {
        // - Deserialize JSON to NewsAPIResponse
        // - Handle exceptions
        System.debug('** Raw jsonResponse: ' + jsonResponse);
        NewsAPIResponse articleList = (NewsAPIResponse) JSON.deserialize(jsonResponse, NewsAPIResponse.class);
        if(articleList.articles.isEmpty()){
            return null;
        }
        else {
            for(NewsAPIResponse.Article art: articleList.articles){
                try{
                    art = new NewsAPIResponse.Article(art);
                    NewsAPIResponse.Source newSource = new NewsAPIResponse.Source(art.source);
                    art.source = newSource;
                } catch (Exception ex){
                    Error errorInfo = new Error(ex);
                    errorInfo.logError();
                    throw new NewsApiProcessingException('*** News Api Processing Exception: ' + ex.getMessage());
                }
            }
            
        }
        return articleList;
    }
    
    private static List<String> createCategoryList(){
        return new List<String>{'business','entertainment','general','health','science','sports','technology'};
    }
    
    /**
     * Custom exception class for NewsAPI errors
     */
    public class NewsAPIProcessingException extends Exception {}
}