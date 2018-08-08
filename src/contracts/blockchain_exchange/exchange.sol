pragma solidity ^0.4.21;

import './owned.sol';
import './erc20.sol';
import './safemath.sol';

contract exchange is owned {
  using SafeMath for uint;

  //자료구조
  struct Offer {
    uint amount;
    address who;
  }

  struct OrderBook {
    uint higherPrice;
    uint lowerPrice;

    mapping (uint => Offer) offers;
    uint offers_key;
    uint offers_length;
  }

  struct Token {
    address tokenContract;
    string symbolName;

    mapping (uint => OrderBook) buyBook;
    uint curBuyPrice;
    uint lowestBuyPrice;
    uint amountBuyPrices;

    mapping (uint => OrderBook) sellBook;
    uint curSellPrice;
    uint highestSellPrice;
    uint amountSellPrices;
  }

  mapping (uint => Token) tokens;
    uint tokenIndex;

  //주소별 토큰 잔고
  mapping (address => mapping (uint => uint)) tokenBalanceForAddress;
  //주소별 이더리움 잔고
  mapping (address => uint ) balanceEthForAddress;

  //이벤트
  event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
  event WithdrawalToken (address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
  event DepositForEthReceived (address indexed _from, uint _amount, uint _timestamp);
  event WithdrawalEth (address indexed _to, uint _amount, uint _timestamp);

  event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
  event BuyOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
  event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
  event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
  event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);
  event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);
  event orderBookCleared(uint indexed _symbolIndex, bool _isBuyOrderBook, uint _priceInWei );

  event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);


  //이더 입금
  function depositEther() public payable {
    balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].add(msg.value);
    emit DepositForEthReceived(msg.sender, msg.value, now);
  }

  //이더 출금
  function WithdrawalEther (uint amountInWei) public {
    require(balanceEthForAddress[msg.sender] >= amountInWei);
    balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].sub(amountInWei);
    msg.sender.transfer(amountInWei);
    emit WithdrawalEth(msg.sender, amountInWei, now);
  }

  //이더 잔액 확인
  function getEthBalanceInWei() view public returns (uint) {
    return balanceEthForAddress[msg.sender];
  }


  //거래소에 토큰 추가
  function addToken(string symbolName, address erc20TokenAddress) public onlyowner {
    require(!hasToken(symbolName));
    tokenIndex = tokenIndex.add(1);

    tokens[tokenIndex].symbolName = symbolName;
    tokens[tokenIndex].tokenContract = erc20TokenAddress;
    emit TokenAddedToSystem(tokenIndex, symbolName, now);
  }

  //거래소에 특정 토큰이 존재하나 확인
  function hasToken(string symbolName) view public returns (bool) {
    uint index = getSymbolIndex(symbolName);
    if (index == 0) {
      return false;
    }
    return true;
  }

  //거래소에 등록된 토큰의 인덱스 받아옴
  function getSymbolIndex(string symbolName) internal view returns (uint) {
    for (uint i = 1; i <= tokenIndex; i++) {
      if (compareStrings(tokens[i].symbolName, symbolName)) {
        return i;
      }
    }
    return 0;
  }

  //솔리디티는 직접적인 string 비교가 불가능하여 해시값으로 비교
  function compareStrings (string a, string b) internal view returns (bool){
       return keccak256(a) == keccak256(b);
   }

  //토큰이 존재하는지 확인하고 존재하면 인덱스를 반환, 없으면 revert
  function getSymbolIndexOrThrow(string symbolName) internal view returns (uint) {
    uint index = getSymbolIndex(symbolName);
    require( index > 0 );
    return index;
  }


  //토큰 입금
  //유저가 거래소에게 aprrove한 후에 이용할 수 있음 (transferFrom함수 사용)
  function depositToken(string symbolName, uint amount) public {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[tokenIndex].tokenContract != address(0));

    ERC20Interface token = ERC20Interface(tokens[tokenIndex].tokenContract);

    require(token.transferFrom(msg.sender, address(this), amount) == true);
    tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].add(amount);
    emit DepositForTokenReceived(msg.sender, tokenIndex, amount, now);
  }

  //토큰 출금
  function withdrawToken(string symbolName, uint amount) public {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[tokenIndex].tokenContract != address(0));

    ERC20Interface token = ERC20Interface(tokens[tokenIndex].tokenContract);

    require(tokenBalanceForAddress[msg.sender][tokenIndex] - amount >= 0);
    tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].sub(amount);
    require(token.transfer(msg.sender, amount)==true);
    emit WithdrawalToken(msg.sender, tokenIndex, amount, now);
  }

  //토큰 잔액 확인
  function getTokenBalance(string symbolName) view public returns (uint) {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    return tokenBalanceForAddress[msg.sender][tokenIndex];
  }


  //구매 오더북을 받아오는 함수
  function getBuyOrderBook(string symbolName) view public returns (uint[], uint[]) {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    //동적으로 배열 길이를 할당할 수 있음
    uint[] memory arrPricesBuy = new uint[](tokens[tokenIndex].amountBuyPrices);
    uint[] memory arrVolumesBuy = new uint[](tokens[tokenIndex].amountBuyPrices);

    //가장 낮은 가격부터 가격을 올려가며 가격을 받아옴
    uint whilePrice = tokens[tokenIndex].lowestBuyPrice;
    uint counter = 0;
    if (tokens[tokenIndex].curBuyPrice > 0) {
      while (whilePrice <= tokens[tokenIndex].curBuyPrice) {
        arrPricesBuy[counter] = whilePrice;
        uint volumeAtPrice = 0;
        uint offers_key = 0;

        //각 가격대 안에 존재하는 모든 오퍼의 물량을 합산
        offers_key = tokens[tokenIndex].buyBook[whilePrice].offers_key;
        while (offers_key <= tokens[tokenIndex].buyBook[whilePrice].offers_length) {
          volumeAtPrice = volumeAtPrice.add(tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount);
          offers_key = offers_key.add(1);
        }
        arrVolumesBuy[counter] = volumeAtPrice;

        //더이상 높은 가격이 없을 경우 while문 탈출
        if(tokens[tokenIndex].buyBook[whilePrice].higherPrice == 0) {
          break;
        }
        else {
          whilePrice = tokens[tokenIndex].buyBook[whilePrice].higherPrice;
        }
        counter = counter.add(1);
      }
    }
    return (arrPricesBuy, arrVolumesBuy);
  }

  //판매 오더북을 받아오는 함수 (위와 같은 구조)
  function getSellOderBook (string symbolName) view public returns (uint[], uint[]) {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    uint[] memory arrPricesSell = new uint[](tokens[tokenIndex].amountSellPrices);
    uint[] memory arrVolumesSell = new uint[](tokens[tokenIndex].amountSellPrices);
    uint sellWhilePrice = tokens[tokenIndex].curSellPrice;
    uint sellCounter = 0;

    if (tokens[tokenIndex].curSellPrice > 0 ) {
      while(sellWhilePrice <= tokens[tokenIndex].highestSellPrice) {
        arrPricesSell[sellCounter] = sellWhilePrice;
        uint sellVolumeAtPrice = 0;
        uint sell_offers_key = 0;

        sell_offers_key = tokens[tokenIndex].sellBook[sellWhilePrice].offers_key;
        while (sell_offers_key <= tokens[tokenIndex].sellBook[sellWhilePrice].offers_length) {
          sellVolumeAtPrice = sellVolumeAtPrice.add(tokens[tokenIndex].sellBook[sellWhilePrice].offers[sell_offers_key].amount);
          sell_offers_key = sell_offers_key.add(1);
        }
        arrVolumesSell[sellCounter] = sellVolumeAtPrice;

        if( tokens[tokenIndex].sellBook[sellWhilePrice].higherPrice == 0) {
          break;
        }
        else{
          sellWhilePrice = tokens[tokenIndex].sellBook[sellWhilePrice].higherPrice;
        }
        sellCounter = sellCounter.add(1);
      }
    }
    return (arrPricesSell, arrVolumesSell);
  }



  //토큰 구매
  function buyToken(string symbolName, uint priceInWei, uint amount) public {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    uint total_amount_ether_necessary = 0;


    //현재 판매물량이 없거나 판매가격이 구매가보다 높은 경우 오더북에 현재가 주문 추가
    if(tokens[tokenIndex].amountSellPrices == 0 || tokens[tokenIndex].curSellPrice > priceInWei) {

      total_amount_ether_necessary = amount.mul(priceInWei);
      require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
      //구매자 이더 차감
      balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].sub(total_amount_ether_necessary);
      //오더북에 주문 추가
      addBuyOffer(tokenIndex, priceInWei, amount, msg.sender);
      emit LimitBuyOrderCreated(tokenIndex, msg.sender, amount, priceInWei, tokens[tokenIndex].buyBook[priceInWei].offers_length);
    }
    else {
      //시장 가격으로 구매
      uint total_amount_ether_available = 0;
      uint whilePrice = tokens[tokenIndex].curSellPrice;
      uint amountNecessary = amount;
      uint offers_key;
      //현재판매가격이 구매 희망가격보다 높아지거나 물량이 소진될때까지 while문 작동
      while(whilePrice <= priceInWei && amountNecessary > 0 ) {

        offers_key = tokens[tokenIndex].sellBook[whilePrice].offers_key;

        //whilePrice가격에서 오퍼를 확인한다
        while(offers_key <= tokens[tokenIndex].sellBook[whilePrice].offers_length && amountNecessary > 0 ) {
          //현재 시장 가격중 현재키에 대응하는 오퍼의 볼륨
          uint volumeAtPriceFromAddress = tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].amount;
          //현재 오퍼의 볼륨이 구매하려는 양보다 적을 때, 현재 오퍼를 모두 구매한 뒤 다음 오퍼로 진행
          if(volumeAtPriceFromAddress <= amountNecessary) {
            total_amount_ether_available = volumeAtPriceFromAddress.mul(whilePrice);
            require(balanceEthForAddress[msg.sender] >= total_amount_ether_available);
            //구매자 이더 차감
            balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].sub(total_amount_ether_available);
            //오더북에서 토큰 차감
            tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].amount = 0;
            //판매자 이더 증가
            balanceEthForAddress[tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].who] = balanceEthForAddress[tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].who].add(total_amount_ether_available);
            //구매자 토큰 증가
            tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].add(volumeAtPriceFromAddress);
            //구매된 양만큼 구매 희망 물량에서 차감
            amountNecessary = amountNecessary.sub(volumeAtPriceFromAddress);
            emit SellOrderFulfilled(tokenIndex, volumeAtPriceFromAddress, whilePrice, offers_key);
            //오퍼의 key값을 올려 다음 오퍼로 넘어감
            tokens[tokenIndex].sellBook[whilePrice].offers_key = tokens[tokenIndex].sellBook[whilePrice].offers_key.add(1);
          }
          //현재 오퍼의 볼륨이 구매하려는 양보다 많으면, 현 오퍼에서 전부 구매
          else {
            total_amount_ether_necessary = amountNecessary.mul(whilePrice);
            require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);

            //구매자 이더 차감, 오더북에서 토큰 차감, 구매자 토큰 증가, 판매자 이더 증가
            balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].sub(total_amount_ether_necessary);
            tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].amount = tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].amount.sub(amountNecessary);
            tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].add(amountNecessary);
            balanceEthForAddress[tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].who] = balanceEthForAddress[tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].who].add(total_amount_ether_necessary);

            amountNecessary = 0;
            emit SellOrderFulfilled(tokenIndex, volumeAtPriceFromAddress, whilePrice, offers_key);
          }
          //현 가격대에서 마지막 오퍼까지 전부 소진했을 경우 현 가격대 오더북 초기화 및 다음 가격대로 이동
          if(offers_key == tokens[tokenIndex].sellBook[whilePrice].offers_length && tokens[tokenIndex].sellBook[whilePrice].offers[offers_key].amount == 0) {
            //현 가격대 뿐만이 아닌 다음 가격도 존재하지 않는 경우, 즉 더이상 판매 오더가 없는 경우
            if (tokens[tokenIndex].sellBook[whilePrice].higherPrice == 0 ) {
              tokens[tokenIndex].curSellPrice = 0;
              tokens[tokenIndex].highestSellPrice = 0;
            }
            else {
              //다음 가격이 존재하는 경우 curSellPrice를 다음 단계로 높힌다
              tokens[tokenIndex].curSellPrice = tokens[tokenIndex].sellBook[whilePrice].higherPrice;
              tokens[tokenIndex].sellBook[tokens[tokenIndex].curSellPrice].lowerPrice = 0;
            }
            clearOrderBook(tokenIndex, false, whilePrice);
          }
          offers_key = offers_key.add(1);
        }
        whilePrice = tokens[tokenIndex].curSellPrice;
        //현재 가격이 0이면 오더북에 아무것도 없다는 뜻이니 while문을 탈출한다
        if(whilePrice == 0) {
          break;
        }
      }
      //구매가 전부 다 이뤄지지 않았을 때 남은 양을 시장에 걸어두기
      if(amountNecessary > 0 ) {
        buyToken(symbolName, priceInWei, amountNecessary);
      }
    }
  }

  //오더북에 현재가 주문 추가
  function addBuyOffer(uint tokenIndex, uint priceInWei, uint amount, address who) internal {
    tokens[tokenIndex].buyBook[priceInWei].offers_length = tokens[tokenIndex].buyBook[priceInWei].offers_length.add(1);
    tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);

    //만약 이 가격대에 첫 오퍼일 경우 curBuyPrice, lowestBuyPrice, lowerPrice, higherPrice를 설정해줘야 함
    if (tokens[tokenIndex].buyBook[priceInWei].offers_length == 1) {
      tokens[tokenIndex].buyBook[priceInWei].offers_key = 1;
      tokens[tokenIndex].amountBuyPrices = tokens[tokenIndex].amountBuyPrices.add(1);

      uint curBuyPrice = tokens[tokenIndex].curBuyPrice;
      uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;

      if (lowestBuyPrice == 0 || lowestBuyPrice > priceInWei) {
        //판매 오더가 아예 존재하지 않는 경우
        if (curBuyPrice == 0) {
          tokens[tokenIndex].curBuyPrice = priceInWei;
          tokens[tokenIndex].lowestBuyPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].higherPrice = 0;
          tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
        }
        else {
          //구매 주문 가격이 최저가인 경우
          tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
          tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
          tokens[tokenIndex].lowestBuyPrice = priceInWei;
        }
      }
      else if (curBuyPrice < priceInWei) {
        //최고가인 경우
        tokens[tokenIndex].buyBook[curBuyPrice].higherPrice = priceInWei;
        tokens[tokenIndex].buyBook[priceInWei].higherPrice = 0;
        tokens[tokenIndex].buyBook[priceInWei].lowerPrice = curBuyPrice;
        tokens[tokenIndex].curBuyPrice = priceInWei;
      }
      else {
        //기존에 존재하는 가격대 사이에 끼어넣어야 할 경우에는 적절한 위치를 찾아야 한다
        uint buyPrice = tokens[tokenIndex].curBuyPrice;
        bool weFountIt = false;
        while(buyPrice > 0 && !weFountIt) {
          //priceInWei, 즉 희망구매가 buyPrice와 buyPrice의 higherPrice사이에 위치할 때 까지 buyPrice를 낮춰가면서 찾는다
          if( buyPrice < priceInWei && tokens[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei ) {

            tokens[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
            tokens[tokenIndex].buyBook[priceInWei].higherPrice = tokens[tokenIndex].buyBook[buyPrice].higherPrice;

            tokens[tokenIndex].buyBook[tokens[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
            tokens[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

            weFountIt = true;
          }
          buyPrice = tokens[tokenIndex].buyBook[buyPrice].lowerPrice;
        }
      }
    }
  }

  //토큰 판매
  function sellToken(string symbolName, uint priceInWei, uint amount) public {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);

    //구매 물량이 없거나 구매 희망가보다 판매가가 높은 경우
    if (tokens[tokenIndex].amountBuyPrices == 0 || tokens[tokenIndex].curBuyPrice < priceInWei) {
      require(tokenBalanceForAddress[msg.sender][tokenIndex] >= amount);
      tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].sub(amount);
      addSellOffer(tokenIndex, priceInWei, amount, msg.sender);

      emit LimitSellOrderCreated( tokenIndex, msg.sender, amount, priceInWei, tokens[tokenIndex].sellBook[priceInWei].offers_length );

    }
    else {
      //구매 물량이 존재하여 마켓가격으로 판매해야 할 경우 가장 높은 가격(curBuyPrice)부터 낮춰가면서 구매한다
      uint whilePrice = tokens[tokenIndex].curBuyPrice;
      uint amountNecessary = amount;
      uint offers_key;

      while ( whilePrice >= priceInWei && amountNecessary > 0 ) {

        offers_key = tokens[tokenIndex].buyBook[whilePrice].offers_key;

        //현재 가격의 오퍼를 하나씩 하나씩 올려가며 물량 소진
        while(offers_key <= tokens[tokenIndex].buyBook[whilePrice].offers_length && amountNecessary > 0 ) {
          uint volumeAtPriceFromAddress = tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount;

          //현재 오퍼에서 모든 물량 소화 가능할 경우
          if (amountNecessary < volumeAtPriceFromAddress ) {
            require(tokenBalanceForAddress[msg.sender][tokenIndex] >= amountNecessary);

            //판매자 토큰 수 차감
            tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].sub(amountNecessary);
            //구매 오퍼에서 토큰 수 차감
            tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount = tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount.sub(amountNecessary);
            //구매자 토큰 수 증가
            tokenBalanceForAddress[tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].who][tokenIndex] = tokenBalanceForAddress[tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].who][tokenIndex].add(amountNecessary);
            //판매자 이더 증가
            balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].add(amountNecessary.mul(whilePrice));
            //물량 차감
            amountNecessary = 0;

            emit SellOrderFulfilled(tokenIndex, amountNecessary, whilePrice, offers_key);
          }
        //현재 가격의 구매 오더북에서 현 오퍼의 구매물량이 판매하려는 양보다 같거나 작은 경우 현 오퍼 물량을 전부 체결하고 다음 오퍼로 넘어감
          else {
            require(tokenBalanceForAddress[msg.sender][tokenIndex] >= volumeAtPriceFromAddress);

            //판매자 토큰 수 차감
            tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].sub(volumeAtPriceFromAddress);
            //구매 오퍼 제거
            tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount = 0;
            //구매자 토큰 수 증가
            tokenBalanceForAddress[tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].who][tokenIndex] = tokenBalanceForAddress[tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].who][tokenIndex].add(volumeAtPriceFromAddress);
            //판매자 이더 증가
            balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].add(volumeAtPriceFromAddress.mul(whilePrice));
            //물량 차감
            amountNecessary = amountNecessary.sub(volumeAtPriceFromAddress);
            emit SellOrderFulfilled(tokenIndex, volumeAtPriceFromAddress, whilePrice, offers_key);

            //오퍼키 증가
            tokens[tokenIndex].buyBook[whilePrice].offers_key = tokens[tokenIndex].buyBook[whilePrice].offers_key.add(1);

            //만약 다음 오퍼가 없을 경우 현 오퍼를 초기화하고 다음 가격으로 넘어감
            if (offers_key == tokens[tokenIndex].buyBook[whilePrice].offers_length && tokens[tokenIndex].buyBook[whilePrice].offers[offers_key].amount == 0) {
              //더 낮은 가격이 없는 경우
              if (tokens[tokenIndex].buyBook[whilePrice].lowerPrice == 0) {
                tokens[tokenIndex].curBuyPrice = 0;
                tokens[tokenIndex].lowestBuyPrice = 0;
              }
              else {
                //더 낮은 가격이 있는 경우 다음 가격의 오더북을 현재 오더북으로 설정
                tokens[tokenIndex].curBuyPrice = tokens[tokenIndex].buyBook[whilePrice].lowerPrice;
                tokens[tokenIndex].buyBook[tokens[tokenIndex].curBuyPrice].higherPrice = 0;
              }
              //오더북 초기화
              clearOrderBook(tokenIndex, true, whilePrice);
            }
          }
          offers_key = offers_key.add(1);
        }
        //whilePrice가격 재설정
        whilePrice = tokens[tokenIndex].curBuyPrice;
        //현재 가격이 0이면 오더북에 아무것도 없다는 뜻이니 while문을 탈출한다
        if(whilePrice == 0) {
          break;
        }
      }
      //판매하지 못한 물량이 남아있을 시
      if ( amountNecessary > 0 ) {
        sellToken(symbolName, priceInWei, amountNecessary);
      }
    }
  }

  function addSellOffer(uint tokenIndex, uint priceInWei, uint amount, address who) internal {

    tokens[tokenIndex].sellBook[priceInWei].offers_length = tokens[tokenIndex].sellBook[priceInWei].offers_length.add(1);
    tokens[tokenIndex].sellBook[priceInWei].offers[tokens[tokenIndex].sellBook[priceInWei].offers_length] = Offer(amount, who);

    //이 가격대에 기존 오더북이 없을 경우 추가 설정이 필요함
    if (tokens[tokenIndex].sellBook[priceInWei].offers_length == 1 ) {
      tokens[tokenIndex].sellBook[priceInWei].offers_key = 1;
      tokens[tokenIndex].amountSellPrices = tokens[tokenIndex].amountSellPrices.add(1);

      uint curSellPrice = tokens[tokenIndex].curSellPrice;
      uint highestSellPrice = tokens[tokenIndex].highestSellPrice;

      if (highestSellPrice == 0 || highestSellPrice < priceInWei) {
        if (curSellPrice == 0) {
          //오더가 아예 존재하지 않는 경우
          tokens[tokenIndex].curSellPrice = priceInWei;
          tokens[tokenIndex].highestSellPrice = priceInWei;
        }
        else {
          //가장 높은 오더일 경우
          tokens[tokenIndex].sellBook[highestSellPrice].higherPrice = priceInWei;
          tokens[tokenIndex].sellBook[priceInWei].lowerPrice = highestSellPrice;
          tokens[tokenIndex].highestSellPrice = priceInWei;
        }
      }
      else if (curSellPrice > priceInWei) {
        //가장 낮은 오더일 경우
        tokens[tokenIndex].sellBook[curSellPrice].lowerPrice = priceInWei;
        tokens[tokenIndex].sellBook[priceInWei].higherPrice = curSellPrice;
        tokens[tokenIndex].curSellPrice = priceInWei;
      }
      else {
        //중간에 끼어넣어야 할 경우
        uint sellPrice = tokens[tokenIndex].curSellPrice;
        bool weFountIt = false;
        while(sellPrice > 0 && !weFountIt) {
          //priceInWei가 sellPrice와 sellPrice의 lowerPrice 사이일때까지 sellPrice를 높혀가면서 찾는다
          if( sellPrice < priceInWei && tokens[tokenIndex].sellBook[sellPrice].higherPrice > priceInWei ) {

            tokens[tokenIndex].sellBook[priceInWei].lowerPrice = sellPrice;
            tokens[tokenIndex].sellBook[priceInWei].higherPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;

            tokens[tokenIndex].sellBook[tokens[tokenIndex].sellBook[sellPrice].higherPrice].lowerPrice = priceInWei;
            tokens[tokenIndex].sellBook[sellPrice].higherPrice = priceInWei;

            weFountIt = true;
          }
          sellPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;
        }
      }
    }
  }

  //주문 취소하는 함수
  //왜인지 모르겠지만 특정한경우에 주문 취소 시 오더북 받아오기가 제대로 작동하지 않아서 고민중..
  function cancelOrder (string symbolName, bool isBuyOrder, uint priceInWei, uint offerKey) public {
    uint tokenIndex = getSymbolIndexOrThrow(symbolName);
    if (isBuyOrder) {
      require(tokens[tokenIndex].buyBook[priceInWei].offers[offerKey].who == msg.sender);
      uint etherToRefund = tokens[tokenIndex].buyBook[priceInWei].offers[offerKey].amount.mul(priceInWei);
      tokens[tokenIndex].buyBook[priceInWei].offers[offerKey].amount = 0;
      balanceEthForAddress[msg.sender] = balanceEthForAddress[msg.sender].add(etherToRefund);
      emit BuyOrderCanceled (tokenIndex, priceInWei, offerKey);

      //이 가격대에 남아있는 물량이 있는지 확인후 없다면 이 가격대 오더북 초기화
      uint buy_offers_length = tokens[tokenIndex].buyBook[priceInWei].offers_length;
      if (buy_offers_length == tokens[tokenIndex].buyBook[priceInWei].offers_key && tokens[tokenIndex].buyBook[priceInWei].offers[buy_offers_length].amount == 0 ) {
        clearOrderBook(tokenIndex, true, priceInWei);
      }
    }
    else {
      require(tokens[tokenIndex].sellBook[priceInWei].offers[offerKey].who == msg.sender);
      uint tokenToRefund = tokens[tokenIndex].sellBook[priceInWei].offers[offerKey].amount;

      tokens[tokenIndex].sellBook[priceInWei].offers[offerKey].amount = 0;
      tokenBalanceForAddress[msg.sender][tokenIndex] = tokenBalanceForAddress[msg.sender][tokenIndex].add(tokenToRefund);
      emit SellOrderCanceled (tokenIndex, priceInWei, offerKey);

      //이 가격대에 남아있는 물량이 있는지 확인후 없다면 이 가격대의 오더북 초기화
      uint sell_offers_length = tokens[tokenIndex].sellBook[priceInWei].offers_length;
      if (sell_offers_length == tokens[tokenIndex].sellBook[priceInWei].offers_key && tokens[tokenIndex].sellBook[priceInWei].offers[sell_offers_length].amount == 0 ) {
        clearOrderBook(tokenIndex, false, priceInWei);
      }
    }
  }

  //오더북 초기화
  function clearOrderBook (uint tokenIndex, bool isBuyOrderBook, uint priceInWei ) internal {
    if (isBuyOrderBook) {
      tokens[tokenIndex].amountBuyPrices = tokens[tokenIndex].amountBuyPrices.sub(1);
      tokens[tokenIndex].buyBook[priceInWei].offers_length = 0;
      tokens[tokenIndex].buyBook[priceInWei].offers_key = 0;
      tokens[tokenIndex].buyBook[priceInWei].higherPrice = 0;
      tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
      emit orderBookCleared( tokenIndex, true, priceInWei );
    }
    else {
      tokens[tokenIndex].amountSellPrices = tokens[tokenIndex].amountSellPrices.sub(1);
      tokens[tokenIndex].sellBook[priceInWei].offers_length = 0;
      tokens[tokenIndex].sellBook[priceInWei].offers_key = 0;
      tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
      tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
      emit orderBookCleared( tokenIndex, false, priceInWei );
    }
  }
}
