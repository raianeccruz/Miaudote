<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnimalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $imagem = null;

        if ($this->imagem) {
            $caminho = public_path('storage/' . $this->imagem);

            if (is_file($caminho)) {
                $conteudo = file_get_contents($caminho);
                $tipo = mime_content_type($caminho) ?: 'image/jpeg';

                if ($conteudo !== false) {
                    $imagem = 'data:' . $tipo . ';base64,' . base64_encode($conteudo);
                }
            }
        }

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'nome' => $this->nome,
            'especie' => $this->especie,
            'idade' => $this->idade,
            'descricao' => $this->descricao,
            'cidade' => $this->cidade,
            'estado' => $this->estado,
            'status' => $this->status,
            'imagem' => $imagem,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
