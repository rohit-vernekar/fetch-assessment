FROM continuumio/miniconda3

WORKDIR /app

# Install dependencies
COPY environment.yml .
RUN conda env create -f environment.yml && conda clean -a

# Activate the environment and ensure it’s activated in bash
RUN echo "conda activate fetch" >> ~/.bashrc
ENV PATH /opt/conda/envs/fetch/bin:$PATH

# Copy the rest of the application
COPY . .

# Expose the Jupyter Notebook port
EXPOSE 8888

# Run Jupyter Notebook with appropriate settings for container access
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
