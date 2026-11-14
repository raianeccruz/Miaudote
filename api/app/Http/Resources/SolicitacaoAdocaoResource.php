<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SolicitacaoAdocaoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,

            'animal' => $this->whenLoaded('animal', function () {
                return [
                    'id' => $this->animal->id,
                    'nome' => $this->animal->nome,
                    'especie' => $this->animal->especie,
                    'imagem' => $this->animal->imagem ? asset('storage/' . $this->animal->imagem) : null,
                ];
            }),

            'usuario' => $this->whenLoaded('usuario', function () {
                return [
                    'id' => $this->usuario->id,
                    'nome' => $this->usuario->name,
                ];
            }),

            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
