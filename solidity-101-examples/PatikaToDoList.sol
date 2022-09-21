
pragma solidity ^0.8.3;

contract toDoList {
    struct toDo {
        string text;
        bool completed;
    }

    toDo[] public toDos;

    function create(string calldata _text) external {
        toDos.push(toDo(_text,false));
    }

    function updateText(uint _index, string calldata _text) external {
        toDos[_index].text = _text;
    }

    function get(uint _index) external view returns (string memory, bool){
        toDo storage ToDo = toDos[_index];
        return (ToDo.text, ToDo.completed);
    }

    function toggleCompleted(uint _index) external {
        toDos[_index].completed = !toDos[_index].completed;
    }
}