const config = require('./nodejs-app-crud-config.json')
const Pool = require('pg').Pool
const pool = new Pool({
    host: config.postgres.host,
    port: config.postgres.port,
    user: config.postgres.user,
    password: config.postgres.password,
    database: config.postgres.database,
})
const getEmails = (request, response) => {
  pool.query('SELECT * FROM emails ORDER BY id ASC', (error, results) => {
    if (error) {
      response.status(500).send(`Error: ${error.message}`)
      return
    }
    response.status(200).json(results.rows)
  })
}

const getEmailById = (request, response) => {
  const id = parseInt(request.params.id)

  pool.query('SELECT * FROM emails WHERE id = $1', [id], (error, results) => {
    if (error) {
      response.status(500).send(`Error: ${error.message}`)
      return
    }
    response.status(200).json(results.rows)
  })
}

const createEmail = (request, response) => {
  const { name, email } = request.body

  pool.query('INSERT INTO emails (name, email) VALUES ($1, $2) RETURNING id', [name, email], (error, results) => {
    if (error) {
      response.status(500).send(`Error: ${error.message}`)
      return
    }
    response.status(201).send(`Email added with ID: ${results.rows[0].id}`)
  })
}

const updateEmail = (request, response) => {
  const id = parseInt(request.params.id)
  const { name, email } = request.body

  pool.query(
    'UPDATE emails SET name = $1, email = $2 WHERE id = $3',
    [name, email, id],
    (error, results) => {
      if (error) {
        response.status(500).send(`Error: ${error.message}`)
        return
      }
      response.status(200).send(`Email modified with ID: ${id}`)
    }
  )
}

const deleteEmail = (request, response) => {
  const id = parseInt(request.params.id)

  pool.query('DELETE FROM emails WHERE id = $1', [id], (error, results) => {
    if (error) {
      response.status(500).send(`Error: ${error.message}`)
      return
    }
    response.status(200).send(`Email deleted with ID: ${id}`)
  })
}

module.exports = {
  getEmails,
  getEmailById,
  createEmail,
  updateEmail,
  deleteEmail,
}