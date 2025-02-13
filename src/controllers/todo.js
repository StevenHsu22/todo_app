const Todo = require('../models/todo');

// search ToDo tasks
exports.getTodos = async (req, res) => {
  try {
    const todos = await Todo.findAll();
    res.json(todos);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.addTodo = async (req, res) => {
  const { title, description, priority } = req.body;
  
  if (!title || !description) {
    return res.status(400).json({ message: 'Title and Description are required' });
  }

  try {
    const newTodo = await Todo.create({
      title,
      description,
      priority: priority || 0, // if priority is not provided, set it to 0
    });
    res.status(201).json(newTodo);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// update ToDo tasks
exports.updateTodo = async (req, res) => {
  const { id } = req.params;
  const { title, description, priority } = req.body;

  if (!title || !description) {
    return res.status(400).json({ message: 'Title and Description are required' });
  }

  try {
    // search for the ToDo task with the specified ID
    const todo = await Todo.findByPk(id);
    if (!todo) {
      return res.status(404).json({ message: 'Todo not found' });
    }

    await todo.update({
      title,
      description,
      priority,
    });
    res.json(todo);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// delete ToDo tasks
exports.deleteTodo = async (req, res) => {
  const { id } = req.params;

  try {
    const todo = await Todo.findByPk(id);
    if (!todo) {
      return res.status(404).json({ message: 'Todo not found' });
    }

    await todo.destroy();
    res.json({ message: 'Todo deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};