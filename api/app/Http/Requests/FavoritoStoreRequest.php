<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class FavoritoStoreRequest extends FormRequest
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
            'animal_id' => 'required|integer|exists:animais,id', // Valida se o animal_id é fornecido, é um inteiro e existe na tabela 'animais'
        ];
    }

    public function messages(): array
    {
        return [
            'animal_id.required' => 'O animal é obrigatório.',
            'animal_id.integer' => 'O identificador do animal deve ser um número.',
            'animal_id.exists' => 'O animal informado não existe.',
        ];
    }
}
