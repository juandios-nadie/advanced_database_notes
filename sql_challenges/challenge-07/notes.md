### SECTION 6:
##### Activity – Your Turn

• The activity asked to test 3 different kinds of searches in the vector database  
• Search 1 was something directly in the article  
• Search 2 was something related but not an exact quote  
• Search 3 was something unrelated  
• The purpose was to compare how semantic search behaves in each case  

### SECTION 7:
##### Activity outputs and what I found

• Search 1: `How do vector indexes work?`  
  • Top preview 1: `A vector database, vector store or vector search engine is a database that stores and retrieves embe...`  
  • Top preview 2: `Vector embeddings are mathematical representations of data in a high-dimensional space. In this spac...`  
  • What I found: the results were clearly related to the article, so yes, it made sense  
  • Interpretation: even though the preview did not literally answer everything about indexes, it still returned relevant chunks about vector databases and embeddings  

• Search 2: `fast similarity search at scale`  
  • Top preview 1: `In recent benchmarks, HNSW-based implementations have been among the best performers. Conferences su...`  
  • Top preview 2: `Vector databases are used in a wide range of machine learning applications including similarity sear...`  
  • What I found: yes, it found relevant content even though those exact words were not necessarily written the same way in the article  
  • Interpretation: this shows the vector DB is matching by meaning, not just exact keyword overlap  

• Search 3: `If you had a color what color`  
  • Returned chunk IDs: `2`, `5`, and `6`  
  • Preview 1: `Vector embeddings a...` — similarity score `0.9357`  
  • Preview 2: `Vector database...` — similarity score `0.9545`  
  • Preview 3: `An especially commo...` — similarity score `0.9707`  
  • What I found: the scores were high and the results were not really related to the question  
  • Interpretation: this happened because the question was unrelated to the article, so the semantic distance was large  

### Final takeaway from the activity:

• Search 1 gave relevant results because the question was directly about the article  
• Search 2 also gave useful results because vector search understands related meaning  
• Search 3 gave weak matches and high scores because the question was unrelated  
• A score closer to `0.0` means more similarity  
• A score closer to `1.0` means less similarity  
• This activity proved that vector search finds meaning, not just keywords  