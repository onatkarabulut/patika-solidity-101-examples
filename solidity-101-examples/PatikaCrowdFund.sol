pragma solidity ^0.8.10;

import "./IERC20.sol";

contract CrowdFund {

    event Launch(uint id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Cancel(uint id);
    event Pledged(uint indexed _id, address indexed caller, uint amount);
    event Unpledged(uint indexed _id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedTokens;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        count += 1;
        campaigns[count] = Campaign(msg.sender, _goal, 0, _startAt, _endAt, false);
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_id];
        emit Cancel(_id);
    }
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.startAt, "not started");
        require(block.timestamp >= campaign.endtAt, "ended");
        campaign.pledged += _amount;
        pledgedTokens[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledged(_id, msg.sender, _amount);

    }
    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.endtAt, "ended");
        campaign.pledged -= _amount;
        pledgedTokens[_id][msg.sender] += _amount;
        emit Unpledged(_id, msg.sender, _amount);
    }
    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == creator, "not creator");
        require(block.timestamp < campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");
        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_id);
   }
    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");

        uint bal = pledgedTokens[_id][msg.sender];
        pledgedTokens[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id, msg.sender, bal);
    }

}