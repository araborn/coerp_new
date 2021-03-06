xquery version "3.0";

module namespace search="http://localhost:8080/exist/apps/coerp_new/search";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/coerp_new/config" at "config.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace coerp="http://coerp.uni-koeln.de/schema/coerp";
import module namespace kwic="http://exist-db.org/xquery/kwic";

(: ###### SUCH FUNKTIONEN ######### :)

declare function search:Search_Authors-Translator_StWi($type as xs:string, $letter as xs:string) {
    
         let $db := collection("/db/apps/coerp_new/data/texts")
        let $range := concat("//range:field-starts-with(('",$type,"'),'",$letter,"')")
         let $build := concat("$db",$range)
        return util:eval($build)
};
declare function search:RangeSearch_Starts-With($type as xs:string, $letter as xs:string, $db as node()*) {
        let $range := concat("//range:field-starts-with(('",$type,"'),'",$letter,"')")
         let $build := concat("$db",$range)
        return util:eval($build)
};

declare function search:FindDocument($text as xs:string) {
(:for $hit in collection("/db/apps/coerp_new/data/texts")//coerp:short_title/data(.)
        return if ($hit = $text) then
      root($hit)/util:document-name(.)
      else ():)
   root(search:RangeSearch_simple(collection("/db/apps/coerp_new/data/texts"),"short_title",xmldb:decode-uri($text)))/util:document-name(.) 

};

declare function search:range-MultiStats($db as node()*, $name as xs:string*, $case as xs:string*,$content as xs:string*) as node()* {
    let $name := concat('("',string-join($name,'","'),'")')
    let $case := concat('("',string-join($case,'","'),'")')
    let $content := concat('"',string-join($content,'","'),'"')
    let $search-funk := concat('//range:field(',$name,',',$case,',',$content,')')
    let $search-build := concat("$db",$search-funk)
    return util:eval($search-build)
};

declare function search:RangeSearch_simple($db as node()*,$param as xs:string, $term as xs:string) {
        let $search_terms := concat('("',$param,'"),"',$term,'"')
        let $search_funk := concat("//range:field-contains(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)

};

declare function search:range-date($db as node()*,$from as xs:string, $to as xs:string,$param as xs:string) {
    for $date in (xs:integer($from) to xs:integer($to)) return search:range-date-func($db,xs:string($date),$param)
};

declare function search:range-date-func($db as node()*,$date as xs:string,$param as xs:string) {
        let $search_terms := concat('("',$param,'"),"',$date,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

(: ########### SEARCH SEITEN AUFBAU ############# :)

declare function search:test($node as node()*, $model as map(*)) {
   request:get-parameter("name",'')
};


declare function search:CollectData($node as node(), $model as map(*)) {
       (: let $db := collection("/db/apps/coerp_new/data") :)
         let $dbase := collection("/db/apps/coerp_new/data/texts")
         let $term :=  if(search:get-parameters("term") != "") then $dbase//coerp:coerp[ft:query(.,request:get-parameter("term",''))]
                                     else $dbase
        let $dbase := $term
       
        let $date := search:get-date-results($dbase) 
        let $dbase := $date
        let $genre := if(search:get-parameters("genre") != "") then search:get-range-search($dbase,"genre")
                                else $dbase
        let $dbase := $genre
        let $denom := if(search:get-parameters("denom") != "") then search:get-range-search($dbase,"denom")
                                else $dbase
        let $dbase := $denom
        
        return map {
        "results" :=  $dbase,
        "query" := request:get-parameter("term",''),
        "sum" := fn:count($dbase)
        }
        
        
};


declare function search:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                    else ()
                
};




declare function search:get-date-results($db as node()*) {
      let $date := request:get-parameter("date","")
      let $from := xs:integer(substring-before($date," -"))
        let $to := xs:integer(substring-after($date,"- "))
        for $year in ($from to $to)
            return search:get-date-search($db,$year)
};


declare function search:get-range-search($db as node()*,$param as xs:string) {
        for $hit in search:get-parameters($param)    
        let $search_terms := concat('("',$param,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)

};

declare function search:get-date-search($db as node()*, $year as xs:string) {
        let $search_terms := concat('("year_from"),"',$year,'"')
        let $search_funk := concat("//range:field-contains(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        return util:eval($search_build)
};

declare function search:AnalyzeResultsExt($node as node(), $model as map(*)) {
if($model("query") != "") then
    let $db := $model("result")
    let $expanded := kwic:expand($db)
return map {
"kwic" := kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)
}
else map {
    "kwic" := ""
}

};

