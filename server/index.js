const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const responses = [
  "This is a random response.",
  "Here's another random text.",
  "Randomness is key!",
  "Hello from the server!",
  "You sent something, and this is a random reply."
];

app.post('/api/random-text', (req, res) => {
  const { text } = req.body;
  console.log(`Received text: ${text}`);

  // Select a random response
  const randomResponse = responses[Math.floor(Math.random() * responses.length)];

  res.json({ response: randomResponse });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
