{{
    codegen.generate_source(
        schema_name = 'SQL_SERVER_DBO',
        database_name = 'AQUERO_DEV_BRONZE_DB',
        table_names = ['orders','order_items'],
        generate_columns = True,
        include_descriptions=True,
        include_data_types=True,
        name='sql_server_dbo',
        include_database=True,
        include_schema=True
        )
}}

