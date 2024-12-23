# Multihead Neural Network

## Sentence Transformer Implementation

For the sentence transformer implementation, I used the `distilbert-base-uncased` tokenizer and model from the Hugging Face Transformers library. DistilBERT is a compact version of BERT (Bidirectional Encoder Representations from Transformers), designed to be faster and lighter while retaining a high degree of performance. It has approximately 60% fewer parameters than BERT-base, making it computationally efficient without sacrificing too much accuracy.

**Process:**
1. **Tokenization:**  
   The `distilbert-base-uncased` tokenizer converts each input sentence into a sequence of tokens. This includes tokenizing words, converting them to lowercase, and appending special tokens like `[CLS]` (classification token at the beginning of the sequence) and `[SEP]` (separator token at the end of the sequence). The tokenized output is fed into the model as input.

2. **Encoding and Embedding Extraction:**
   The DistilBERT model processes the tokenized input, producing embeddings for each token in the sentence. To obtain a single fixed-length sentence embedding:
   - I extracted the embedding of the `[CLS]` token, which is commonly used as a representative embedding for the entire sentence. 
   - Alternatively, sentence embeddings could be generated by averaging the embeddings across the last hidden states of all tokens in the sequence, which also captures the overall meaning of the sentence effectively.

3. **Resulting Sentence Embedding:**
   The output sentence embedding is a vector of length 768, as DistilBERT has a hidden size of 768. This 768-dimensional vector represents the semantic content of the sentence, making it suitable for downstream NLP tasks such as classification or similarity measurement.

---

## Multi-Task Learning Expansion

To expand the Sentence Transformer into a multi-task learning (MTL) setup, I defined two separate task-specific heads on top of the DistilBERT model:

1. **Sentiment Classification Head**: This head classifies the sentiment of the sentence (e.g., positive, neutral, or negative).
2. **Sentence Classification Head**: This head classifies the sentence into predefined categories, serving as a general-purpose classifier.

Each of these heads consists of two hidden layers with dimensions `[100, 50]`. These dimensions were chosen arbitrarily to balance complexity and computational efficiency while still providing enough capacity for meaningful classification.

#### Architectural Changes to Support Multi-Task Learning
To enable MTL, I added these two task-specific heads on top of the transformer backbone. The modifications include:
- **Separate Linear Layers**: Each head has its own set of linear layers to process the shared embeddings from the transformer and adapt them to the specific classification tasks.
- **Independent Output Layers**: Each head’s output layer is specific to its task. This setup allows each head to learn features unique to its task while leveraging the shared transformer backbone for common sentence representation.

---
## Training Considerations
#### Freezing Strategy
To maintain efficiency while adapting the model to multiple tasks, I decided to **freeze most of the layers in the transformer backbone**, keeping only a few layers trainable. Specifically:
- I froze all layers **except for `layer.5.output_layer_norm` and `layer.5.ffn`** (Feed-Forward Network).
  
**Rationale for Freezing Layers**:
- **Efficiency**: Freezing the majority of the transformer layers reduces the computational cost, making the model more efficient to train and deploy.
- **Preserving Pre-Trained Knowledge**: Since DistilBERT is already pre-trained on a large corpus, freezing the earlier layers helps retain its general language understanding, which is useful across multiple tasks.
- **Focused Adaptation**: By leaving only `layer.5.output_layer_norm` and `layer.5.ffn` trainable, we allow the model to adapt selectively. These specific layers are closer to the output, allowing them to fine-tune the shared representation for our specific tasks without extensively modifying the entire network, which could lead to overfitting or loss of generalization.

---
## Layer-wise Learning Rate Implementation

- **Task-Specific Heads**: I set a relatively higher learning rate (`1e-3`) for the sentiment classification and sentence classification heads, as these layers are newly added and need to be trained from scratch. A higher learning rate allows them to adapt quickly to the specific tasks.
- **Unfrozen Transformer Layers**: For the selected transformer layers (`layer.5.output_layer_norm` and `layer.5.ffn`), I used a lower learning rate (`5e-5`). These layers are pre-trained but unfrozen to allow fine-tuning. A lower learning rate helps retain the pre-trained knowledge while slowly adapting the model for the multi-task setup.

#### Benefits of Layer-Wise Learning Rates
1. **Faster Convergence**: Applying higher learning rates to newly added task-specific heads enables these layers to converge faster without waiting for the entire network to catch up.
2. **Stability in Pre-Trained Layers**: Lower learning rates in the unfrozen transformer layers help retain the general linguistic understanding from pre-training, preventing drastic weight updates that could degrade performance.
3. **Better Task Adaptation**: In a multi-task setup, layer-wise learning rates allow the task-specific heads to specialize quickly, while the shared layers adapt at a slower, more stable pace, thus balancing generalization and task-specific learning.
4. **Reduced Interference**: By controlling the rate of adaptation in shared layers, we reduce the risk of "interference" between tasks, which can happen if one task disrupts another’s learning.
---

## Results

The dataset contained a total of 11,914 reviews, each annotated with a corresponding sentiment label and class label. Due to time constraints, I trained the model on a subset of only 500 samples. Despite the limited training data, the model achieved the following performance:

- **Sentiment Classification Accuracy**: 0.74
- **Class Classification Accuracy**: 0.89

These results demonstrate the model's capability to learn and generalize even with a small dataset, though there is certainly room for improvement. Increasing the number of training samples would likely enhance the model's accuracy by allowing it to learn more robust features. Additionally, a more complex architecture could further improve performance by capturing finer details in the data.
