# Session – 2026-04-07

## Topics covered

• vector databases
• embeddings
• semantic search
• chunking text into paragraphs
• SentenceTransformer model
• Oracle 23ai vector type
• loading vectors into a database
• natural language search with cosine distance

## What I understood

• A vector database stores text together with a numeric representation of its meaning called an embedding
• Instead of searching only exact words, vector search compares meanings
• We can take a long article, split it into chunks, and turn each chunk into a vector
• In this activity, each paragraph chunk got converted into a 384-dimension vector
• The model `all-MiniLM-L6-v2` was used to create embeddings
• Oracle 23ai can store vectors directly using the `VECTOR(384, FLOAT32)` datatype
• A query is also converted into an embedding, and then the database compares that query vector against stored chunk vectors
• `VECTOR_DISTANCE(..., COSINE)` measures how close two meanings are
• A score closer to 0.0 means the result is more similar, and closer to 1.0 means less similar
• This is why vector databases are useful for semantic search, RAG, and AI assistants

### SECTION 1:

##### Build the vector search pipeline

• Choose one article as the dataset

```python
ARTICLE_CHOICE = 1

ARTICLES = {
    1: "Vector database",
    2: "Word embedding",
    3: "Semantic search",
}

ARTICLE_TITLE = ARTICLES[ARTICLE_CHOICE]
print(f"You chose: '{ARTICLE_TITLE}'")
```

• Fetch the Wikipedia article text

```python
wiki = wikipediaapi.Wikipedia(
    user_agent="oracle-vector-search-lesson/1.0",
    language="en"
)

page = wiki.page(ARTICLE_TITLE)
print(f"✓ Fetched: {page.title}")
```

• Split the article into useful chunks

```python
raw_paragraphs = [p.strip() for p in page.text.split('\n') if len(p.strip()) > 120]
```

• Generate embeddings for every chunk

```python
model = SentenceTransformer("all-MiniLM-L6-v2")
embeddings = model.encode(chunks, show_progress_bar=True)
```

### SECTION 2:

##### Store vectors in Oracle 23ai

• Create a table to save the text and its vector

```sql
CREATE TABLE doc_chunks (
    chunk_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doc_name     VARCHAR2(200),
    chunk_text   VARCHAR2(2000),
    chunk_vector VECTOR(384, FLOAT32)
);
```

• Each row stores one text chunk and one embedding
• `chunk_text` keeps the readable paragraph
• `chunk_vector` keeps the numeric meaning representation

### SECTION 3:

##### Insert the embeddings into the database

• The notebook formats every embedding as an Oracle vector literal

```python
def format_vector(embedding):
    values = ", ".join(f"{v:.8f}" for v in embedding)
    full = f"[{values}]"
    mid = len(full) // 2
    split_pos = full.rindex(',', 0, mid) + 1
    part1 = full[:split_pos]
    part2 = full[split_pos:]
    return f"TO_VECTOR(TO_CLOB('{part1}') || '{part2}', 384, FLOAT32)"
```

• The split with `TO_CLOB() || ...` is used because Oracle rejects very long string literals at parse time
• So the vector is split into two parts and then rebuilt when inserted

### SECTION 4:

##### Search by meaning, not by exact keywords

• Convert the question into an embedding

```python
MY_QUESTION = "What is a vector database used for?"
q_emb = model.encode([MY_QUESTION])[0]
q_vec = format_vector(q_emb)
```

• Search the most similar chunks in Oracle

```sql
SELECT
    chunk_id,
    SUBSTR(chunk_text, 1, 100) AS preview,
    ROUND(VECTOR_DISTANCE(chunk_vector, q_vec, COSINE), 4) AS similarity_score
FROM doc_chunks
ORDER BY similarity_score ASC
FETCH FIRST 3 ROWS ONLY;
```

• The database returns the chunks whose meaning is closest to the question
• This works even if the exact same words are not in the article

### SECTION 5:

##### Main idea of vector databases

• A normal database can store information, but a vector database is especially useful when we want similarity search
• The important part is not only the text, but its embedding
• That lets the system answer questions in natural language
• This is the base idea behind semantic search and many AI tools

### Practice observations:

##### What the activity wanted us to notice

• If we ask something that is clearly in the article, the returned chunks should make sense
• If we ask something related but phrased differently, vector search can still find relevant content
• If we ask something unrelated, the score should be worse because the meanings are far apart

### Final takeaway:

• Vector DBs do not search only by matching words
• They search by comparing embeddings
• Embeddings are numeric vectors that represent meaning
• Oracle 23ai can store and search those vectors directly
• This makes vector databases very useful for semantic search, recommendation systems, and AI assistants
