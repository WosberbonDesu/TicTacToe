import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  Game _game = Game();
  bool _isPlayingWithAI = true;

  @override
  void initState() {
    super.initState();
    _game = Game();
  }

  void _handleTap(int row, int col) {
    if (!_game.isGameOver()) {
      setState(() {
        _game.playMove(row, col);
        if (_game.isGameOver()) {
          _showGameOverDialog();
        } else if (_isPlayingWithAI && !_game.isAITurn()) {
          _game.makeAIMove();
          if (_game.isGameOver()) {
            _showGameOverDialog();
          }
        }
      });
    }
  }

  void _showGameOverDialog() {
    String message;
    if (_game.hasWinner()) {
      message = 'Player ${_game.getWinner()} wins!';
    } else {
      message = 'It\'s a tie!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                setState(() {
                  _game.reset();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCell(int row, int col) {
    final cellValue = _game.getCellValue(row, col);
    return GestureDetector(
      onTap: () {
        if (cellValue.isEmpty) {
          _handleTap(row, col);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Center(
          child: Text(
            cellValue,
            style: TextStyle(fontSize: 48),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildCell(0, 0),
                _buildCell(0, 1),
                _buildCell(0, 2),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildCell(1, 0),
                _buildCell(1, 1),
                _buildCell(1, 2),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildCell(2, 0),
                _buildCell(2, 1),
                _buildCell(2, 2),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Play with AI'),
                Switch(
                  value: _isPlayingWithAI,
                  onChanged: (value) {
                    setState(() {
                      _isPlayingWithAI = !_isPlayingWithAI;
                      _game.reset();
                    });
                  },
                ),
                Text('Play with 2nd User'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Board {
  late List<List<String>> _cells;

  Board() {
    _cells = List.generate(3, (_) => List.filled(3, ''));
  }

  void reset() {
    _cells = List.generate(3, (_) => List.filled(3, ''));
  }

  bool isCellEmpty(int row, int col) {
    return _cells[row][col].isEmpty;
  }

  void setCell(int row, int col, String value) {
    _cells[row][col] = value;
  }

  String getCellValue(int row, int col) {
    return _cells[row][col];
  }

  bool isBoardFull() {
    for (var row in _cells) {
      if (row.contains('')) {
        return false;
      }
    }
    return true;
  }

  bool hasPlayerWon(String player) {
    // Check rows
    for (var row in _cells) {
      if (row.every((cell) => cell == player)) {
        return true;
      }
    }

    // Check columns
    for (var col = 0; col < 3; col++) {
      if (_cells[0][col] == player &&
          _cells[1][col] == player &&
          _cells[2][col] == player) {
        return true;
      }
    }

    // Check diagonals
    if (_cells[0][0] == player &&
        _cells[1][1] == player &&
        _cells[2][2] == player) {
      return true;
    }
    if (_cells[0][2] == player &&
        _cells[1][1] == player &&
        _cells[2][0] == player) {
      return true;
    }

    return false;
  }
}

class Game {
  Board _board = Board();
  String _currentPlayer = "";
  String _aiPlayer = "";

  Game() {
    _board = Board();
    _currentPlayer = 'X';
    _aiPlayer = 'O';
  }

  void reset() {
    _board.reset();
    _currentPlayer = 'X';
  }

  String getCellValue(int row, int col) {
    return _board.getCellValue(row, col);
  }

  String getCurrentPlayer() {
    return _currentPlayer;
  }

  bool isAITurn() {
    return _currentPlayer == _aiPlayer;
  }

  void playMove(int row, int col) {
    if (_board.isCellEmpty(row, col) && !isGameOver()) {
      _board.setCell(row, col, _currentPlayer);
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    }
  }

  void makeAIMove() {
    if (isAITurn()) {
      List<int> availableMoves = [];
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (_board.isCellEmpty(i, j)) {
            availableMoves.add(i * 3 + j);
          }
        }
      }
      if (availableMoves.isNotEmpty) {
        Random random = Random();
        int randomMove = availableMoves[random.nextInt(availableMoves.length)];
        int row = randomMove ~/ 3;
        int col = randomMove % 3;
        _board.setCell(row, col, _aiPlayer);
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    }
  }

  bool hasWinner() {
    return _board.hasPlayerWon('X') || _board.hasPlayerWon('O');
  }

  String getWinner() {
    if (_board.hasPlayerWon('X')) {
      return 'X';
    } else if (_board.hasPlayerWon('O')) {
      return 'O';
    }
    return '';
  }

  bool isGameOver() {
    return hasWinner() || _board.isBoardFull();
  }
}
