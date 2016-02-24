grammar Utiaji::Server::Grammar {
     rule TOP {
        <verb> '/' 'HTTP/1.1' \n
        <headers>
        \n
     }
     token ws { \h* }
     token verb {
         GET | POST | PUT
     }
     token path {
         '/' <segment>* %% '/'
     }
     token segment {
         [ <alpha> | <digit> | '+' | '-' | '.' ]*
     }
     rule headers {
         [ <header> \n ]*
     }
     rule header {
         <field-name> ':' <field-value>
     }
     token field-name {
         <-[:]>+
     }
     token field-value {
         <-[\n]>+
     }
}


