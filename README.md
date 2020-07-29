# MultipeerConnectivity
Point-to-point connection data transmission


```
        A                           B
         |       --invite-->        |
         |                          |
         |       <--accept--        |
         |                          |
         |        --send-->         |
         |                          |
         |       <--receive--       |
         |                          |
         |        ........          |
         |                          |
         |      --send done-->      |
         |                          |
         |           close          |
         
```
### A state becomed notConnected, and then stops broadcasting

### View
![](https://github.com/HatsuneMikuV/MultipeerConnectivity/blob/master/test.gif)
