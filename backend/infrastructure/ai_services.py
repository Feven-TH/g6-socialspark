from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.output_parsers import StructuredOutputParser
from langchain.prompts import PromptTemplate
from pydantic import BaseModel
from typing import Type
import os
from dotenv import load_dotenv

load_dotenv()

def get_llm():
    """
    Returns the Gemini Model object to be invoked by the caller.
    """
    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        raise ValueError("GOOGLE_API_KEY not found in environment variables.")
    
    llm = ChatGoogleGenerativeAI(model="gemini-pro", google_api_key=api_key)
    return llm


def get_structured_response(prompt_template_str: str, input_variables: dict, pydantic_model: Type[BaseModel]):
    """
    Generates a structured Pydantic object based on a prompt template and a Pydantic model.
    """
    llm = get_llm()
    
    parser = StructuredOutputParser.from_pydantic_model(pydantic_model)
    format_instructions = parser.get_format_instructions()
    
    prompt = PromptTemplate(
        template=prompt_template_str + "\n{format_instructions}\n",
        input_variables=list(input_variables.keys()),
        partial_variables={"format_instructions": format_instructions}
    )
    
    chain = prompt | llm | parser
    
    response = chain.invoke(input_variables)
    
    return response
