<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FavoritoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,

            'animal' => $this->whenLoaded('animal', function () {
                $animal = $this->animal;
                $imagem = null;

                if ($animal->imagem) {
                    $caminho = public_path('storage/' . $animal->imagem);

                    if (is_file($caminho)) {
                        $conteudo = file_get_contents($caminho);
                        $tipo = mime_content_type($caminho) ?: 'image/jpeg';

                        if ($conteudo !== false) {
                            $imagem = 'data:' . $tipo . ';base64,' . base64_encode($conteudo);
                        }
                    }
                }

                return [
                    'id' => $animal->id,
                    'nome' => $animal->nome,
                    'especie' => $animal->especie,
                    'idade' => $animal->idade,
                    'cidade' => $animal->cidade,
                    'estado' => $animal->estado,
                    'status' => $animal->status,
                    'imagem' => $imagem,
                ];
            }),

            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
