<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('animais', function (Blueprint $table) {
            $table->string('cidade');
            $table->char('estado', 2);
            $table->string('status')->default('disponível');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('animais', function (Blueprint $table) {
            $table->dropColumn(['cidade', 'estado', 'status']);
        });
    }
};
