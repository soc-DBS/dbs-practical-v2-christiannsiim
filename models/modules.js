const { PrismaClient, Prisma } = require('@prisma/client');
const prisma = new PrismaClient();

// CREATE operation
// existing createModule function
module.exports.create = function create(code, name, credit) {
    const sql = `INSERT INTO module (mod_code, mod_name, credit_unit) VALUES ($1, $2, $3)`;
    return query(sql, [code, name, credit]).catch(function (error) {
        if (error.code === SQL_ERROR_CODE.UNIQUE_VIOLATION) {
            throw new UNIQUE_VIOLATION_ERROR(`Module ${code} already exists`);
        }
        throw error;
    });
};

// CREATE operation
module.exports.create = function create(code, name, credit) {
    return prisma.module.create({
        //TODO: Add data
        data: {
            modCode: code,      // Maps to mod_code in database
            modName: name,      // Maps to mod_name in database
            creditUnit: parseInt(credit)  // Maps to credit_unit in database, Convert string to integer
        }
    }).then(function (module) {
        //TODO: Return module
        return module;  // Return the created module
    }).catch(function (error) {
        // Prisma error codes: https://www.prisma.io/docs/orm/reference/error-reference#p2002
        // TODO: Handle Prisma Error, throw a new error if module already exists
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
            if (error.code === 'P2002') {
                // P2002 = Unique constraint violation
                throw new Error(`The module ${code} already exists`);
            }
        }
        // Re-throw any other errors
        throw error;
    });
};

// TODO: Add other CRUD operations (Update, Delete, Retrieve) here later