<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class AnimalStoreRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'nome' =>'required|string|max:255',
            'especie' =>'required|string|max:255',
            'idade' =>'required|integer',
            'descricao' =>'required|string',
            'cidade' =>'required|string|max:255',
            'estado' =>'required|string|size:2',
            'imagem' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ];
    }

    public function messages(): array
    {
        return [
            'required' => 'O campo :attribute é obrigatório.',
            'string' => 'O campo :attribute deve ser um texto.',
            'integer' => 'O campo :attribute deve ser um número inteiro.',
            'min' => 'O campo :attribute deve ter pelo menos :min caracteres.',
            'max' => 'O campo :attribute não pode ter mais de :max caracteres.',
            'size' => 'O campo :attribute deve ter exatamente :size caracteres.',
            'image' => 'O campo :attribute deve ser uma imagem.',
            'mimes' => 'O campo :attribute deve ter o formato JPG, JPEG, PNG ou WEBP.',
        ];
    }

    public function attributes(): array
    {
        return [
            'nome' => 'nome',
            'especie' => 'espécie',
            'idade' => 'idade',
            'descricao' => 'descrição',
            'cidade' => 'cidade',
            'estado' => 'estado',
            'imagem' => 'imagem',
        ];
    }
}
