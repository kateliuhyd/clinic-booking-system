import mysql.connector
from mysql.connector import Error, pooling
from contextlib import contextmanager
from config import DB_CONFIG
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create connection pool
try:
    connection_pool = mysql.connector.pooling.MySQLConnectionPool(**DB_CONFIG)
    logger.info("Database connection pool created successfully")
except Error as e:
    logger.error(f"Error creating connection pool: {e}")
    connection_pool = None

@contextmanager
def get_db_connection():
    """
    Context manager for database connections.
    Ensures connections are properly closed even if an error occurs.
    """
    connection = None
    try:
        if connection_pool:
            connection = connection_pool.get_connection()
            yield connection
        else:
            raise Exception("Connection pool not available")
    except Error as e:
        logger.error(f"Database connection error: {e}")
        if connection:
            connection.rollback()
        raise
    finally:
        if connection and connection.is_connected():
            connection.close()

def execute_query(query, params=None, fetch_one=False, fetch_all=False, commit=True):
    """
    Execute a query with proper error handling and connection management.
    
    Args:
        query: SQL query string
        params: Query parameters (tuple or dict)
        fetch_one: Return single result
        fetch_all: Return all results
        commit: Whether to commit the transaction
    
    Returns:
        Query results or None on error
    """
    try:
        with get_db_connection() as connection:
            cursor = connection.cursor(dictionary=True, prepared=True)
            
            # Log query for debugging (remove in production)
            logger.debug(f"Executing query: {query[:100]}...")
            
            cursor.execute(query, params or ())
            
            if fetch_one:
                result = cursor.fetchone()
            elif fetch_all:
                result = cursor.fetchall()
            else:
                if commit:
                    connection.commit()
                result = cursor.lastrowid
            
            cursor.close()
            return result
            
    except Error as e:
        logger.error(f"Database error: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return None

def execute_transaction(queries):
    """
    Execute multiple queries in a transaction.
    
    Args:
        queries: List of (query, params) tuples
    
    Returns:
        True if successful, False otherwise
    """
    try:
        with get_db_connection() as connection:
            cursor = connection.cursor(dictionary=True, prepared=True)
            
            for query, params in queries:
                cursor.execute(query, params)
            
            connection.commit()
            cursor.close()
            return True
            
    except Error as e:
        logger.error(f"Transaction error: {e}")
        return False