package com.gymora.controller;

import com.gymora.model.dto.request.GymRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.GymResponse;
import com.gymora.model.enums.GymStatus;
import com.gymora.service.GymService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/gyms")
@RequiredArgsConstructor
@Tag(name = "Gyms", description = "Gym management endpoints")
public class GymController {

    private final GymService gymService;

    @PostMapping
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Register a new gym")
    public ResponseEntity<ApiResponse<GymResponse>> createGym(@Valid @RequestBody GymRequest request) {
        GymResponse response = gymService.createGym(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Gym registered successfully", response));
    }

    @GetMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "List all gyms (Super Admin only)")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getAllGyms() {
        return ResponseEntity.ok(ApiResponse.success(gymService.getAllGyms()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get gym details")
    public ResponseEntity<ApiResponse<GymResponse>> getGymById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(gymService.getGymById(id)));
    }

    @GetMapping("/admin/{adminId}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'GYM_ADMIN')")
    @Operation(summary = "Get gyms by admin")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getGymsByAdmin(@PathVariable Long adminId) {
        return ResponseEntity.ok(ApiResponse.success(gymService.getGymsByAdmin(adminId)));
    }

    @GetMapping("/status/{status}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get gyms by status")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getGymsByStatus(@PathVariable GymStatus status) {
        return ResponseEntity.ok(ApiResponse.success(gymService.getGymsByStatus(status)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Update gym details")
    public ResponseEntity<ApiResponse<GymResponse>> updateGym(
            @PathVariable Long id, @Valid @RequestBody GymRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Gym updated", gymService.updateGym(id, request)));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Approve or reject gym (Super Admin only)")
    public ResponseEntity<ApiResponse<GymResponse>> updateGymStatus(
            @PathVariable Long id, @RequestBody Map<String, String> request) {
        GymStatus status = GymStatus.valueOf(request.get("status").toUpperCase());
        return ResponseEntity.ok(ApiResponse.success("Gym status updated",
                gymService.updateGymStatus(id, status)));
    }
}
