db = db.getSiblingDB('smartify');
db.createCollection('universities');

const universitiesData = cat('/docker-entrypoint-initdb.d/universities.json');
const universities = JSON.parse(universitiesData);

db.universities.insertMany(universities);