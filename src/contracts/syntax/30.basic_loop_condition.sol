pragma solidity ^0.4.23;


contract conditionAndLoop {
    
    function a() {
        // if(1) { //error
            
        // }
        if(true) {
           
        }
    }
    
    function whileSyntax() {
        
        while(true) {
           if(true){
                break;
           } 
        }
        
        do {
            continue;
        } 
        while (true);
        
        for(var i=0;  i<3; i++){
            
        }
    }
    
    // switch case, goto not supported..
}

contract InfiniteLoop {
    function conversionEx() {
        for (uint8 i = 0; i < 1234; i++){
        }
    }
} // uint8 255;