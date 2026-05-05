package com.gymora.controller;

import com.gymora.model.dto.request.TrainerRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.TrainerResponse;
import com.gymora.service.TrainerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/trainers")
@RequiredArgsConstructor
@Tag(name = "Trainers", description = "Trainer management endpoints")
public class TrainerController {

    private final TrainerService trainerService;

    @PostMapping
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Add trainer to gym")
    public ResponseEntity<ApiResponse<TrainerResponse>> createTrainer(
            @Valid @RequestBody TrainerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Trainer added", trainerService.createTrainer(request)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get trainer by ID")
    public ResponseEntity<ApiResponse<TrainerResponse>> getTrainerById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(trainerService.getTrainerById(id)));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get trainer by user ID")
    public ResponseEntity<ApiResponse<TrainerResponse>> getTrainerByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(trainerService.getTrainerByUserId(userId)));
    }

    @GetMapping("/gym/{gymId}")
    @PreAuthorize("hasAnyRole('GYM_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "List gym trainers")
    public ResponseEntity<ApiResponse<List<TrainerResponse>>> getTrainersByGym(@PathVariable Long gymId) {
        return ResponseEntity.ok(ApiResponse.success(trainerService.getTrainersByGym(gymId)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('GYM_ADMIN', 'TRAINER')")
    @Operation(summary = "Update trainer profile")
    public ResponseEntity<ApiResponse<TrainerResponse>> updateTrainer(
            @PathVariable Long id, @RequestBody TrainerRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Trainer updated",
                trainerService.updateTrainer(id, request)));
    }
}
