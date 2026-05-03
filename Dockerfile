
FROM python:3.11-slim
 
WORKDIR /app
 
# Install dbt and Athena adapter
RUN pip install --no-cache-dir \
    dbt-core==1.11.8 \
    dbt-athena-community==1.10.0
 
# Copy dbt project (excluding local artifacts)
COPY dbt_project.yml .
COPY models/ models/
COPY macros/ macros/
COPY analyses/ analyses/
COPY tests/ tests/
COPY seeds/ seeds/
 
# Copy runtime profiles.yml (uses env vars — no hardcoded values)
COPY profiles_template.yml /root/.dbt/profiles.yml
 
CMD ["dbt", "run", "--profiles-dir", "/root/.dbt"]