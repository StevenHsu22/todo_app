const express = require('express');
const router = express.Router();
const todoController = require('../controllers/todo');

// get ToDo tasks
router.get('/', todoController.getTodos);

// create a new ToDo task
router.post('/', todoController.addTodo);

// update an existing ToDo task
router.put('/:id', todoController.updateTodo);

// delete an existing ToDo task
router.delete('/:id', todoController.deleteTodo);

module.exports = router;
