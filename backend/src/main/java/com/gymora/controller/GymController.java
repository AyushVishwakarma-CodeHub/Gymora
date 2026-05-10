package com.gymora.controller;

import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.GymResponse;
import com.gymora.model.enums.GymStatus;
import com.gymora.service.GymService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/gyms")
@RequiredArgsConstructor
public class GymController {

    private final GymService gymService;

    @GetMapping("/pending")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getPendingGyms() {
        List<GymResponse> gyms = gymService.getGymsByStatus(GymStatus.PENDING);
        return ResponseEntity.ok(ApiResponse.success("Pending gyms fetched", gyms));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<GymResponse>> updateGymStatus(
            @PathVariable Long id,
            @RequestParam GymStatus status) {
        GymResponse updatedGym = gymService.updateGymStatus(id, status);
        return ResponseEntity.ok(ApiResponse.success("Gym status updated to " + status, updatedGym));
    }

    @GetMapping("/admin/{adminId}")
    @PreAuthorize("hasRole('GYM_ADMIN') or hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getGymsByAdmin(@PathVariable Long adminId) {
        List<GymResponse> gyms = gymService.getGymsByAdmin(adminId);
        return ResponseEntity.ok(ApiResponse.success("Gyms for admin fetched", gyms));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<GymResponse>> getGymById(@PathVariable Long id) {
        GymResponse gym = gymService.getGymById(id);
        return ResponseEntity.ok(ApiResponse.success("Gym details fetched", gym));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<GymResponse>>> getAllGyms() {
        List<GymResponse> gyms = gymService.getAllGyms();
        return ResponseEntity.ok(ApiResponse.success("All gyms fetched", gyms));
    }

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<GymResponse>>> getActiveGyms() {
        List<GymResponse> gyms = gymService.getGymsByStatus(GymStatus.APPROVED);
        return ResponseEntity.ok(ApiResponse.success("Active gyms fetched", gyms));
    }
}
