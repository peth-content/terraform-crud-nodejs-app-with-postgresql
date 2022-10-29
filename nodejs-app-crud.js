const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const config = require('./nodejs-app-crud-config.json')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: true}))
app.get('/', (request, response) => {
    response.json({ info: 'CRUD Emails with DB Postgres' })
})

const crud = require('./nodejs-app-crud-emails')

app.get('/emails', crud.getEmails)
app.get('/emails/:id', crud.getEmailById)
app.post('/emails', crud.createEmail)
app.put('/emails/:id', crud.updateEmail)
app.delete('/emails/:id', crud.deleteEmail)

app.listen(config.port, () => {
    console.log(`Api running.`)
})